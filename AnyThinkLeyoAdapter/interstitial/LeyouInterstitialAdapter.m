//
//  LeyouInterstitialAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouInterstitialAdapter.h"
#import "LeyouInterstitialCustomEvent.h"
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@interface LeyouInterstitialAdapter()
@property(nonatomic, readonly, strong) LYInterstitialAd *interstitial;
@property(nonatomic, readonly, strong) LeyouInterstitialCustomEvent *customEvent;
@end

@implementation LeyouInterstitialAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [(LYInterstitialAd *)customObject isValid];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    //Here for full screen video ad, we also use id<ATWMInterstitialAd>, for the presenting methods are the same.
    interstitial.customEvent.delegate = delegate;
    [(LYInterstitialAd *)interstitial.customObject showAdFromRootViewController:viewController];
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
            _customEvent = [[LeyouInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"request nil."}];
            [_customEvent trackInterstitialAdLoadFailed:error];
            return;
        }
        _customEvent = (LeyouInterstitialCustomEvent *)request.customEvent;
        _customEvent.requestCompletionBlock = completion;
        if (request.customObject) {
            _interstitial = request.customObject;
            [_customEvent trackInterstitialAdLoaded:_interstitial adExtra:nil];
        } else {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"request.customObject nil."}];
            [_customEvent trackInterstitialAdLoadFailed:error];
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:slotId];
        return;
    }
    _customEvent = [[LeyouInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize adSize = localInfo[kATInterstitialExtraAdSizeKey] ? [localInfo[kATInterstitialExtraAdSizeKey] CGSizeValue] : CGSizeMake(300.0f, 300.0f);
        self->_interstitial = [[LYInterstitialAd alloc] initWithSlotId:serverInfo[@"slot_id"] adSize:adSize];
        self->_interstitial.delegate = self->_customEvent;
        [self->_interstitial loadAd];
    });
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    [LYAdSDKConfig initAppId:info[@"app_id"]];
    
    LeyouInterstitialCustomEvent *customEvent = [[LeyouInterstitialCustomEvent alloc] initWithInfo:info localInfo:info];
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
        
        CGSize adSize = request.extraInfo[kATInterstitialExtraAdSizeKey] ? [request.extraInfo[kATInterstitialExtraAdSizeKey] CGSizeValue] : CGSizeMake(300.0f, 300.0f);
        LYInterstitialAd * interstitial = [[LYInterstitialAd alloc] initWithSlotId:slotId adSize:adSize];
        interstitial.delegate = customEvent;
        [interstitial loadAd];
        request.customObject = interstitial;
    });
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    LYInterstitialAd *interstitial = (LYInterstitialAd *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(interstitial.eCPM) forKey:LY_M_W_E_COST_PRICE];
    [info setObject:@(price.integerValue) forKey:LY_M_W_H_LOSS_PRICE];
    [interstitial sendWinNotificationWithInfo:info];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    LYInterstitialAd *interstitial = (LYInterstitialAd *)customObject;
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
    [interstitial sendLossNotificationWithInfo:info];
}

@end
