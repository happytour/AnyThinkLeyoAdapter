//
//  LeyouRewardedVideoAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouRewardedVideoAdapter.h"
#import "LeyouRewardedVideoCustomEvent.h"
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@interface LeyouRewardedVideoAdapter()
@property(nonatomic, readonly, strong) LeyouRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly, strong) LYRewardVideoAd *rewardVideoAd;
@end

@implementation LeyouRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((LYRewardVideoAd *)customObject).isValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    LeyouRewardedVideoCustomEvent *customEvent = (LeyouRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((LYRewardVideoAd *)rewardedVideo.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [LYAdSDKConfig initAppId:serverInfo[@"app_id"]];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    if (bidId) {
        NSString * slotId = serverInfo[@"slot_id"];
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
        if (request == nil) {
            _customEvent = [[LeyouRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load reward.", NSLocalizedFailureReasonErrorKey:@"request nil."}];
            [_customEvent trackRewardedVideoAdLoadFailed:error];
            return;
        }
        _customEvent = (LeyouRewardedVideoCustomEvent *)request.customEvent;
        _customEvent.requestCompletionBlock = completion;
        if (request.customObject) {
            _rewardVideoAd = request.customObject;
            [_customEvent trackRewardedVideoAdLoaded:_rewardVideoAd adExtra:nil];
        } else {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load reward.", NSLocalizedFailureReasonErrorKey:@"request.customObject nil."}];
            [_customEvent trackRewardedVideoAdLoadFailed:error];
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:slotId];
        return;
    }
    _customEvent = [[LeyouRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *extra = localInfo;
        if (extra[kATAdLoadingExtraUserIDKey] != nil) {
            NSString *userId = extra[kATAdLoadingExtraUserIDKey];
            [LYAdSDKConfig setUserId:userId];
        }
        if (extra[kATAdLoadingExtraMediaExtraKey] != nil) {
            NSString *ext = extra[kATAdLoadingExtraMediaExtraKey];
            self->_rewardVideoAd = [[LYRewardVideoAd alloc] initWithSlotId:serverInfo[@"slot_id"] extra:ext];
        } else {
            self->_rewardVideoAd = [[LYRewardVideoAd alloc] initWithSlotId:serverInfo[@"slot_id"]];
        }
        self->_rewardVideoAd.delegate = self->_customEvent;
        [self->_rewardVideoAd loadAd];
    });
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    [LYAdSDKConfig initAppId:info[@"app_id"]];
    
    LeyouRewardedVideoCustomEvent *customEvent = [[LeyouRewardedVideoCustomEvent alloc] initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    
    LeyouBiddingRequest *request = [LeyouBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"slot_id"];
    request.extraInfo = info;
    request.customEvent = customEvent;
    
    customEvent.slotId = request.unitID;
    
    [[LeyouBiddingManager sharedInstance] saveRequestItem:request withUnitID:request.unitID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * slotId = request.unitID;
        
        NSDictionary *extra = info;
        if (extra[kATAdLoadingExtraUserIDKey] != nil) {
            NSString *userId = extra[kATAdLoadingExtraUserIDKey];
            [LYAdSDKConfig setUserId:userId];
        }
        LYRewardVideoAd *rewardVideoAd;
        if (extra[kATAdLoadingExtraMediaExtraKey] != nil) {
            NSString *ext = extra[kATAdLoadingExtraMediaExtraKey];
            rewardVideoAd = [[LYRewardVideoAd alloc] initWithSlotId:slotId extra:ext];
        } else {
            rewardVideoAd = [[LYRewardVideoAd alloc] initWithSlotId:slotId];
        }
        rewardVideoAd.delegate = customEvent;
        [rewardVideoAd loadAd];
        request.customObject = rewardVideoAd;
    });
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    LYRewardVideoAd *rewardVideoAd = (LYRewardVideoAd *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(rewardVideoAd.eCPM) forKey:LY_M_W_E_COST_PRICE];
    [info setObject:@(price.integerValue) forKey:LY_M_W_H_LOSS_PRICE];
    [rewardVideoAd sendWinNotificationWithInfo:info];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    LYRewardVideoAd *rewardVideoAd = (LYRewardVideoAd *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(price.integerValue) forKey:LY_M_L_WIN_PRICE];
    LYAdBiddingLossReason reason = LYAdBiddingLossReasonOther;
    if (lossType == ATBiddingLossWithLowPriceInNormal || lossType == ATBiddingLossWithLowPriceInHB || lossType == ATBiddingLossWithFloorFilter) {
        reason = LYAdBiddingLossReasonLowPrice;
    } else if (lossType == ATBiddingLossWithBiddingTimeOut) {
        reason = LYAdBiddingLossReasonLoadTimeout;
    } else if (lossType == ATBiddingLossWithExpire) {
        reason = LYAdBiddingLossReasonCacheInvalid;
    }
    [info setObject:@(reason) forKey:LY_M_L_LOSS_REASON];
    [info setObject:@(YES) forKey:LY_M_ADN_IS_BID];
    [info setObject:@(LYAdAdnTypeOther) forKey:LY_M_ADN_TYPE];
    [info setObject:@"other" forKey:LY_M_ADN_NAME];
    [rewardVideoAd sendLossNotificationWithInfo:info];
}

@end
