//
//  LeyouNativeExpressAdRenderer.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeExpressAdRenderer.h"
@import LYAdSDK;

@interface LeyouNativeExpressAdRenderer()
@property (nonatomic, strong) LYNativeExpressAdRelatedView *relatedView;
@end

@implementation LeyouNativeExpressAdRenderer

- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    _customEvent = offer.assets[kATAdAssetsCustomEventKey];
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
   
    self.relatedView = offer.assets[kATAdAssetsCustomObjectKey];
    self.relatedView.delegate = _customEvent;
    self.relatedView.viewController = self.configuration.rootViewController;
    [self.ADView addSubview:self.relatedView.getAdView];
    self.relatedView.getAdView.frame = self.ADView.bounds;
    LYAdSdkUnionType unionType = self.relatedView.unionType;
    if (unionType != LYAdSdkUnionTypeGDT && unionType != LYAdSdkUnionTypeBaidu && unionType != LYAdSdkUnionTypeADX && unionType != LYAdSdkUnionTypeGromore) {
        [self.relatedView render];
    }
    [self.ADView setNeedsLayout];
    [self.ADView layoutIfNeeded];
}

@end
