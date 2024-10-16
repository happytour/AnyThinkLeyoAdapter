//
//  LeyouNativeExpressAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeExpressAdAdapter.h"
#import "LeyouNativeExpressCustomEvent.h"

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@interface LeyouNativeExpressAdAdapter()
@property(nonatomic, readonly, strong) LYNativeExpressAd *nativeExpressAd;
@property(nonatomic, readonly, strong) LeyouNativeExpressCustomEvent *customEvent;
@end

@implementation LeyouNativeExpressAdAdapter

- (void)loadADWithInfo:(nonnull NSDictionary *)serverInfo localInfo:(nonnull NSDictionary *)localInfo completion:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    NSString * slotId = serverInfo[@"slot_id"];
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    if (bidId) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
        if (request == nil) {
            _customEvent = [[LeyouNativeExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load nativexpress.", NSLocalizedFailureReasonErrorKey:@"request nil."}];
            [_customEvent trackNativeAdLoadFailed:error];
            return;
        }
        _customEvent = (LeyouNativeExpressCustomEvent *)request.customEvent;
        _customEvent.requestCompletionBlock = completion;
        
        ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
        if (bidInfo.customObject) {
            [_customEvent trackNativeAdLoaded:@[[_customEvent asset4NativeExpressAdRelatedView:bidInfo.customObject]]];
        } else {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load nativexpress.", NSLocalizedFailureReasonErrorKey:@"bidInfo.customObject nil."}];
            [_customEvent trackNativeAdLoadFailed:error];
        }
        _customEvent.count--;
        if (_customEvent.count <= 0) {
            [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:slotId];
        }
        _customEvent.customObject = request.customObject;
        return;
    }
    _customEvent = [[LeyouNativeExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    NSInteger count = serverInfo[@"request_num"] ? [serverInfo[@"request_num"] integerValue] : 1;
    CGSize adSize = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_nativeExpressAd = [[LYNativeExpressAd alloc] initWithSlotId:slotId adSize:adSize];
        self->_nativeExpressAd.delegate = self->_customEvent;
        [self->_nativeExpressAd loadAdWithCount:count];
        self->_customEvent.customObject = self->_nativeExpressAd;
    });
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {

    LeyouNativeExpressCustomEvent *customEvent = [[LeyouNativeExpressCustomEvent alloc] initWithInfo:info localInfo:info];
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
        NSInteger count = request.extraInfo[@"request_num"] ? [request.extraInfo[@"request_num"] integerValue] : 1;
        CGSize adSize = [request.extraInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
        LYNativeExpressAd * nativeExpressAd = [[LYNativeExpressAd alloc] initWithSlotId:slotId adSize:adSize];
        nativeExpressAd.delegate = customEvent;
        [nativeExpressAd loadAdWithCount:count];
        request.customObject = nativeExpressAd;
    });
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    LYNativeExpressAdRelatedView *relatedView = (LYNativeExpressAdRelatedView *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(relatedView.eCPM) forKey:LY_M_W_E_COST_PRICE];
    [info setObject:@(price.integerValue) forKey:LY_M_W_H_LOSS_PRICE];
    [relatedView sendWinNotificationWithInfo:info];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    LYNativeExpressAdRelatedView *relatedView = (LYNativeExpressAdRelatedView *)customObject;
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
    [relatedView sendLossNotificationWithInfo:info];
}

@end
