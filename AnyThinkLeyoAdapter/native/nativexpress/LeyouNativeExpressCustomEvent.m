//
//  LeyouNativeExpressCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeExpressCustomEvent.h"
#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"
#import <objc/runtime.h>

@interface LeyouNativeExpressCustomEvent()
@property(nonatomic, strong) NSMutableArray* tempObjs;
@property(nonatomic, strong) NSMutableArray* tempBidObjs;
@end

@implementation LeyouNativeExpressCustomEvent


- (NSMutableArray *)tempObjs {
    if (!_tempObjs) {
        _tempObjs = [NSMutableArray array];
    }
    return _tempObjs;
}

- (NSMutableArray *)tempBidObjs {
    if (!_tempBidObjs) {
        _tempBidObjs = [NSMutableArray array];
    }
    return _tempBidObjs;
}

-(NSDictionary *)asset4NativeExpressAdRelatedView:(LYNativeExpressAdRelatedView *) relatedView {
    NSMutableDictionary *asset = [NSMutableDictionary dictionary];
    [asset setValue:self forKey:kATAdAssetsCustomEventKey];
    [asset setValue:relatedView forKey:kATAdAssetsCustomObjectKey];
    [asset setValue:self.slotId forKey:kATNativeADAssetsUnitIDKey];
    // 模版渲染
    [asset setValue:@(YES) forKey:kATNativeADAssetsIsExpressAdKey];
    
    [asset setValue:[NSString stringWithFormat:@"%lf", relatedView.getAdView.frame.size.width] forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
    [asset setValue:[NSString stringWithFormat:@"%lf", relatedView.getAdView.frame.size.height] forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
    return asset;
}


- (void)ly_nativeExpressAdDidLoad:(NSArray<LYNativeExpressAdRelatedView *> * _Nullable)nativeExpressAdRelatedViews error:(NSError * _Nullable)error {
    if (error || nativeExpressAdRelatedViews == nil || nativeExpressAdRelatedViews.count == 0) {
        if (self.isC2SBiding) {
            LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
            request.bidCompletion(nil, error);
            return;
        }
        [self trackNativeAdLoadFailed:error];
        return;
    }
    if (self.isC2SBiding) {
        self.count = nativeExpressAdRelatedViews.count;
        [nativeExpressAdRelatedViews enumerateObjectsUsingBlock:^(LYNativeExpressAdRelatedView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LYAdSdkUnionType unionType = obj.unionType;
            if (unionType == LYAdSdkUnionTypeGDT || unionType == LYAdSdkUnionTypeBaidu || unionType == LYAdSdkUnionTypeADX || unionType == LYAdSdkUnionTypeGromore) {
                [self.tempBidObjs addObject:obj];
                obj.delegate = self;
                [obj render];
            } else {
                LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
                ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(obj.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:obj];
                if (request.bidCompletion) {
                    request.bidCompletion(bidInfo, nil);
                }
            }
        }];
        self.isC2SBiding = NO;
        return;
    }
    
    NSMutableArray* assets = [NSMutableArray array];
    [nativeExpressAdRelatedViews enumerateObjectsUsingBlock:^(LYNativeExpressAdRelatedView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LYAdSdkUnionType unionType = obj.unionType;
        if (unionType == LYAdSdkUnionTypeGDT || unionType == LYAdSdkUnionTypeBaidu || unionType == LYAdSdkUnionTypeADX || unionType == LYAdSdkUnionTypeGromore) {
            [self.tempObjs addObject:obj];
            obj.delegate = self;
            [obj render];
        } else {
            [assets addObject:[self asset4NativeExpressAdRelatedView:obj]];
        }
    }];
    if (assets.count > 0) {
        [self trackNativeAdLoaded:assets];
    }
}

- (void)ly_nativeExpressAdRelatedViewDidRenderSuccess:(LYNativeExpressAdRelatedView *)nativeExpressAdRelatedView {
    LYAdSdkUnionType unionType = nativeExpressAdRelatedView.unionType;
    if (unionType == LYAdSdkUnionTypeGDT || unionType == LYAdSdkUnionTypeBaidu || unionType == LYAdSdkUnionTypeADX || unionType == LYAdSdkUnionTypeGromore) {
        if ([self.tempBidObjs containsObject:nativeExpressAdRelatedView]) {
            [self.tempBidObjs removeObject:nativeExpressAdRelatedView];
            LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(nativeExpressAdRelatedView.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:nativeExpressAdRelatedView];
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
        } else if ([self.tempObjs containsObject:nativeExpressAdRelatedView]) {
            [self.tempObjs removeObject:nativeExpressAdRelatedView];
            NSMutableArray* assets = [NSMutableArray array];
            [assets addObject:[self asset4NativeExpressAdRelatedView:nativeExpressAdRelatedView]];
            [self trackNativeAdLoaded:assets];
        }
    }
}

- (void)ly_nativeExpressAdRelatedViewDidRenderFail:(LYNativeExpressAdRelatedView *)nativeExpressAdRelatedView {
    LYAdSdkUnionType unionType = nativeExpressAdRelatedView.unionType;
    if (unionType == LYAdSdkUnionTypeGDT || unionType == LYAdSdkUnionTypeBaidu || unionType == LYAdSdkUnionTypeADX || unionType == LYAdSdkUnionTypeGromore) {
        NSError * error = [NSError errorWithDomain:@"com.anythink.Leyou" code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"render fail!"}];
        if ([self.tempBidObjs containsObject:nativeExpressAdRelatedView]) {
            [self.tempBidObjs removeObject:nativeExpressAdRelatedView];
            LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
            request.bidCompletion(nil, error);
        } else if ([self.tempObjs containsObject:nativeExpressAdRelatedView]) {
            [self.tempObjs removeObject:nativeExpressAdRelatedView];
            [self trackNativeAdLoadFailed:error];
        }
    }
}

- (void)ly_nativeExpressAdRelatedViewDidExpose:(LYNativeExpressAdRelatedView *)nativeExpressAdRelatedView {
    [self trackNativeAdImpression];
}

- (void)ly_nativeExpressAdRelatedViewDidClick:(LYNativeExpressAdRelatedView *)nativeExpressAdRelatedView {
    [self trackNativeAdClick];
}

- (void)ly_nativeExpressAdRelatedViewDidCloseOtherController:(LYNativeExpressAdRelatedView *)nativeExpressAdRelatedView {
    [self trackNativeAdCloseDetail];
}

- (void)ly_nativeExpressAdRelatedViewDislike:(LYNativeExpressAdRelatedView *)nativeExpressAdRelatedView {
//    [self trackNativeAdClosed];
}

@end
