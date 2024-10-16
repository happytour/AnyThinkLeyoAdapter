//
//  LeyouBannerAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/25.
//

#import "LeyouBannerAdapter.h"
#import "LeyouBannerCustomEvent.h"
#import <AnyThinkBanner/AnyThinkBanner.h>

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@interface LeyouBannerAdapter()
@property(nonatomic, readonly, strong) LYBannerAdView *bannerView;
@property(nonatomic, readonly, strong) LeyouBannerCustomEvent *customEvent;
@end

@implementation LeyouBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [LYAdSDKConfig initAppId:serverInfo[@"app_id"]];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray *, NSError *))completion {
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    if (bidId) {
        NSString * slotId = serverInfo[@"slot_id"];
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
        if (request == nil) {
            _customEvent = [[LeyouBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:@"request nil."}];
            [_customEvent trackBannerAdLoadFailed:error];
            return;
        }
        _customEvent = (LeyouBannerCustomEvent *)request.customEvent;
        _customEvent.requestCompletionBlock = completion;
        if (request.customObject) {
            _bannerView = request.customObject;
            [_customEvent trackBannerAdLoaded:_bannerView adExtra:nil];
        } else {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:@"request.customObject nil."}];
            [_customEvent trackBannerAdLoadFailed:error];
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:slotId];
        return;
    }
    
    _customEvent = [[LeyouBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * slotId = serverInfo[@"slot_id"];
        CGSize adSize = [localInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [localInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        UIViewController * vc = localInfo[kATExtraInfoRootViewControllerKey];
        CGRect adFrame = {CGPointZero, adSize};
        self->_bannerView = [[LYBannerAdView alloc] initWithFrame:adFrame slotId:slotId viewController:vc];
        self->_bannerView.delegate = self->_customEvent;
        [self->_bannerView loadAd];
    });
}

+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    LYBannerAdView *bannerView = banner.bannerView;
    [view addSubview:bannerView];
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    [LYAdSDKConfig initAppId:info[@"app_id"]];
    
    LeyouBannerCustomEvent *customEvent = [[LeyouBannerCustomEvent alloc] initWithInfo:info localInfo:info];
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
        
        CGSize adSize = [request.extraInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [request.extraInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        UIViewController * vc = request.extraInfo[kATExtraInfoRootViewControllerKey];
        CGRect adFrame = {CGPointZero, adSize};
        LYBannerAdView *bannerView = [[LYBannerAdView alloc] initWithFrame:adFrame slotId:slotId viewController:vc];
        bannerView.delegate = customEvent;
        [bannerView loadAd];
        request.customObject = bannerView;
    });
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    LYBannerAdView *bannerView = (LYBannerAdView *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(bannerView.eCPM) forKey:LY_M_W_E_COST_PRICE];
    [info setObject:@(price.integerValue) forKey:LY_M_W_H_LOSS_PRICE];
    [bannerView sendWinNotificationWithInfo:info];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    LYBannerAdView *bannerView = (LYBannerAdView *)customObject;
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
    [bannerView sendLossNotificationWithInfo:info];
}

@end
