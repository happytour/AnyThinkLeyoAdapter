//
//  LeyouNativeAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeAdapter.h"
#import "LeyouNativeCustomEvent.h"
#import <AnyThinkNative/AnyThinkNative.h>

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

#import "LeyouNativeAdAdapter.h"
#import "LeyouNativeExpressAdAdapter.h"

#import "LeyouNativeAdRenderer.h"
#import "LeyouNativeExpressAdRenderer.h"

@interface LeyouNativeAdapter()
@property(nonatomic, strong, readonly) LeyouNativeAdAdapter * nativeAdAdapter;
@property(nonatomic, strong, readonly) LeyouNativeExpressAdAdapter *nativeExpressAdAdapter;
@end

static BOOL EXPRESS = NO;

@implementation LeyouNativeAdapter {
    LeyouNativeAdAdapter * _nativeAdAdapter;
    LeyouNativeExpressAdAdapter *_nativeExpressAdAdapter;
}

- (nonnull instancetype)initWithNetworkCustomInfo:(nonnull NSDictionary *)serverInfo localInfo:(nonnull NSDictionary *)localInfo { 
    self = [super init];
    if (self != nil) {
        [LYAdSDKConfig initAppId:serverInfo[@"app_id"]];
    }
    return self;
}

- (void)loadADWithInfo:(nonnull NSDictionary *)serverInfo localInfo:(nonnull NSDictionary *)localInfo completion:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    BOOL localExpress = [localInfo[kATNativeADAssetsIsExpressAdKey] boolValue];
    BOOL serverExpress = [serverInfo[@"ly_express"] boolValue];
    if (localExpress || serverExpress) {
        EXPRESS = YES;
        [self.nativeExpressAdAdapter loadADWithInfo:serverInfo localInfo:localInfo completion:completion];
    } else {
        EXPRESS = NO;
        [self.nativeAdAdapter loadADWithInfo:serverInfo localInfo:localInfo completion:completion];
    }
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    [LYAdSDKConfig initAppId:info[@"app_id"]];
    
    BOOL localExpress = [info[kATNativeADAssetsIsExpressAdKey] boolValue];
    BOOL serverExpress = [info[@"ly_express"] boolValue];
    if (localExpress || serverExpress) {
        EXPRESS = YES;
        [LeyouNativeExpressAdAdapter bidRequestWithPlacementModel:placementModel unitGroupModel:unitGroupModel info:info completion:completion];
    } else {
        EXPRESS = NO;
        [LeyouNativeAdAdapter bidRequestWithPlacementModel:placementModel unitGroupModel:unitGroupModel info:info completion:completion];
    }
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    if ([customObject isKindOfClass:[LYNativeAdDataObject class]]) {
        [LeyouNativeAdAdapter sendWinnerNotifyWithCustomObject:customObject secondPrice:price userInfo:userInfo];
    } else if ([customObject isKindOfClass:[LYNativeExpressAdRelatedView class]]) {
        [LeyouNativeExpressAdAdapter sendWinnerNotifyWithCustomObject:customObject secondPrice:price userInfo:userInfo];
    }
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    if ([customObject isKindOfClass:[LYNativeAdDataObject class]]) {
        [LeyouNativeAdAdapter sendLossNotifyWithCustomObject:customObject lossType:lossType winPrice:price userInfo:userInfo];
    } else if ([customObject isKindOfClass:[LYNativeExpressAdRelatedView class]]) {
        [LeyouNativeExpressAdAdapter sendLossNotifyWithCustomObject:customObject lossType:lossType winPrice:price userInfo:userInfo];
    }
}

+(Class) rendererClass {
    if (EXPRESS) {
        return [LeyouNativeExpressAdRenderer class];
    } else {
        return [LeyouNativeAdRenderer class];
    }
}

- (LeyouNativeAdAdapter *)nativeAdAdapter {
    if (!_nativeAdAdapter) {
        _nativeAdAdapter = [[LeyouNativeAdAdapter alloc] init];
    }
    return _nativeAdAdapter;
}

- (LeyouNativeExpressAdAdapter *)nativeExpressAdAdapter {
    if (!_nativeExpressAdAdapter) {
        _nativeExpressAdAdapter = [[LeyouNativeExpressAdAdapter alloc] init];
    }
    return _nativeExpressAdAdapter;
}

@end
