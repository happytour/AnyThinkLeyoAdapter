//
//  LeyouNativeAdAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeAdAdapter.h"
#import "LeyouNativeCustomEvent.h"

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@interface LeyouNativeAdAdapter()
@property(nonatomic, strong, readonly) LYNativeAd *nativeAd;
@property(nonatomic, strong, readonly) LeyouNativeCustomEvent *customEvent;
@end

@implementation LeyouNativeAdAdapter

- (void)loadADWithInfo:(nonnull NSDictionary *)serverInfo localInfo:(nonnull NSDictionary *)localInfo completion:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    NSString * slotId = serverInfo[@"slot_id"];
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    
    if (bidId) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
        if (request == nil) {
            _customEvent = [[LeyouNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"request nil."}];
            [_customEvent trackNativeAdLoadFailed:error];
            return;
        }
        _customEvent = (LeyouNativeCustomEvent *)request.customEvent;
        _customEvent.requestCompletionBlock = completion;
        
        ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
        if (bidInfo.customObject) {
            [_customEvent trackNativeAdLoaded:@[[_customEvent asset4NativeAdDataObjec:bidInfo.customObject]]];
        } else {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"bidInfo.customObject nil."}];
            [_customEvent trackNativeAdLoadFailed:error];
        }
        _customEvent.count--;
        if (_customEvent.count <= 0) {
            [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:slotId];
        }
        self->_customEvent.customObject = request.customObject;
        return;
    }
    
    _customEvent = [[LeyouNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    NSInteger count = serverInfo[@"request_num"] ? [serverInfo[@"request_num"] integerValue] : 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_nativeAd = [[LYNativeAd alloc] initWithSlotId:slotId];
        self->_nativeAd.delegate = self->_customEvent;
        [self->_nativeAd loadAdWithCount:count];
        self->_customEvent.customObject = self->_nativeAd;
    });
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {

    LeyouNativeCustomEvent *customEvent = [[LeyouNativeCustomEvent alloc] initWithInfo:info localInfo:info];
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
        
        LYNativeAd * nativeAd = [[LYNativeAd alloc] initWithSlotId:slotId];
        nativeAd.delegate = customEvent;
        [nativeAd loadAdWithCount:count];
        request.customObject = nativeAd;
    });
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    LYNativeAdDataObject *dataObject = (LYNativeAdDataObject *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(dataObject.eCPM) forKey:LY_M_W_E_COST_PRICE];
    [info setObject:@(price.integerValue) forKey:LY_M_W_H_LOSS_PRICE];
    [dataObject sendWinNotificationWithInfo:info];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    LYNativeAdDataObject *dataObject = (LYNativeAdDataObject *)customObject;
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
    [dataObject sendLossNotificationWithInfo:info];
}

@end
