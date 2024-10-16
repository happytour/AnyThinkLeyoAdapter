//
//  LeyouNativeCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeCustomEvent.h"
#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@implementation LeyouNativeCustomEvent

-(NSDictionary *)asset4NativeAdDataObjec:(LYNativeAdDataObject *) dataObject {
    dispatch_group_t image_download_group = dispatch_group_create();
    NSMutableDictionary *asset = [NSMutableDictionary dictionary];
    [asset setValue:self forKey:kATAdAssetsCustomEventKey];
    [asset setValue:dataObject forKey:kATAdAssetsCustomObjectKey];
    [asset setValue:self.slotId forKey:kATNativeADAssetsUnitIDKey];
    // 自渲染
    [asset setValue:@(NO) forKey:kATNativeADAssetsIsExpressAdKey];
    [asset setValue:dataObject.title forKey:kATNativeADAssetsMainTitleKey];
    [asset setValue:dataObject.desc forKey:kATNativeADAssetsMainTextKey];
    [asset setValue:dataObject.iconUrl forKey:kATNativeADAssetsIconURLKey];
    dispatch_group_enter(image_download_group);
    [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:dataObject.iconUrl] completion:^(UIImage *image, NSError *error) {
        if ([image isKindOfClass:[UIImage class]]) {
            asset[kATNativeADAssetsIconImageKey] = image;
        }
        dispatch_group_leave(image_download_group);
    }];
    [asset setValue:dataObject.imageUrl forKey:kATNativeADAssetsImageURLKey];
    dispatch_group_enter(image_download_group);
    [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:dataObject.imageUrl] completion:^(UIImage *image, NSError *error) {
        if ([image isKindOfClass:[UIImage class]]) {
            asset[kATNativeADAssetsMainImageKey] = image;
        }
        dispatch_group_leave(image_download_group);
    }];
    BOOL video = dataObject.creativeType == LYNativeAdCreativeType_GDT_isVideoAd
                     || dataObject.creativeType == LYNativeAdCreativeType_CSJ_VideoImage
                     || dataObject.creativeType == LYNativeAdCreativeType_CSJ_VideoPortrait
                     || dataObject.creativeType == LYNativeAdCreativeType_CSJ_SquareVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_KS_AdMaterialTypeVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_KLN_HorVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_BD_VIDEO
                     || dataObject.creativeType == LYNativeAdCreativeType_GRO_LandscapeVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_GRO_PortraitVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_GRO_SquareVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_GRO_UnionSplashVideo
                     || dataObject.creativeType == LYNativeAdCreativeType_ADX_VIDEO;
    [asset setValue:@(video) forKey:kATNativeADAssetsContainsVideoFlag];
    return asset;
}


- (void)ly_nativeAdDidLoad:(NSArray<LYNativeAdDataObject *> * _Nullable)nativeAdDataObjects error:(NSError * _Nullable)error {
    if (error || nativeAdDataObjects == nil || nativeAdDataObjects.count == 0) {
        if (self.isC2SBiding) {
            LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
            request.bidCompletion(nil, error);
            return;
        }
        [self trackNativeAdLoadFailed:error];
        return;
    }
    if (self.isC2SBiding) {
        self.count = nativeAdDataObjects.count;
        [nativeAdDataObjects enumerateObjectsUsingBlock:^(LYNativeAdDataObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(obj.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:obj];
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
        }];
        self.isC2SBiding = NO;
        return;
    }
    
    NSMutableArray* assets = [NSMutableArray array];
    [nativeAdDataObjects enumerateObjectsUsingBlock:^(LYNativeAdDataObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:[self asset4NativeAdDataObjec:obj]];
    }];
    [self trackNativeAdLoaded:assets];
}

- (void)ly_nativeAdViewDidExpose:(LYNativeAdView *)nativeAdView {
    [self trackNativeAdImpression];
}

- (void)ly_nativeAdViewDidClick:(LYNativeAdView *)nativeAdView {
    [self trackNativeAdClick];
}

- (void)ly_nativeAdViewDidCloseOtherController:(LYNativeAdView *)nativeAdView {
    [self trackNativeAdCloseDetail];
}

- (void)ly_nativeAdViewMediaDidPlayFinish:(LYNativeAdView *)nativeAdView {
    [self trackNativeAdVideoEnd];
}

- (void)ly_nativeAdViewDislike:(LYNativeAdView *)nativeAdView {
//    [self trackNativeAdClosed];
}

@end
