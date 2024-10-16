//
//  LeyouNativeAdRenderer.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import "LeyouNativeAdRenderer.h"
@import LYAdSDK;

@interface LeyouNativeAdRenderer()
@property (nonatomic, strong) LYNativeAdView *nativeAdView;
@property (nonatomic, assign) BOOL refreshData;
@end

@implementation LeyouNativeAdRenderer

- (instancetype)initWithConfiguraton:(ATNativeADConfiguration *)configuration adView:(ATNativeADView *)adView {
    self = [super initWithConfiguraton:configuration adView:adView];
    if (self != nil) {
        self.nativeAdView = [[LYNativeAdView alloc] init];
    }
    return self;
}

- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    _customEvent = offer.assets[kATAdAssetsCustomEventKey];
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
    
    LYNativeAdDataObject * dataObject = offer.assets[kATAdAssetsCustomObjectKey];
    if (self.refreshData == NO) {
        [self.nativeAdView refreshData:dataObject];
    } else {
        self.refreshData = NO;
    }
    self.nativeAdView.autoLayout = YES;
    self.nativeAdView.delegate = _customEvent;
    self.nativeAdView.viewController = self.configuration.rootViewController;
    if (self.ADView.selfRenderView) {
        self.nativeAdView.realAdView.frame = self.ADView.selfRenderView.bounds;
        if (self.nativeAdView != self.nativeAdView.realAdView) {
            self.nativeAdView.frame = self.nativeAdView.realAdView.bounds;
        }
        [self.ADView addSubview:self.nativeAdView];
        [self.nativeAdView.realAdView addSubview:self.ADView.selfRenderView];
        if (self.nativeAdView != self.nativeAdView.realAdView) {
            [self.nativeAdView addSubview:self.nativeAdView.realAdView];
        }
        [self.ADView bringSubviewToFront:self.nativeAdView];
    } else {
        if (self.nativeAdView != self.nativeAdView.realAdView) {
            [self.nativeAdView addSubview:self.nativeAdView.realAdView];
        }
        [self.ADView addSubview:self.nativeAdView];
        [self.ADView bringSubviewToFront:self.nativeAdView];
    }
    NSLog(@"unionType: %ld", dataObject.unionType);
    if (dataObject.unionType == LYAdSdkUnionTypeGDT) {
        UIView *mediaView = self.nativeAdView.mediaView;
        mediaView.translatesAutoresizingMaskIntoConstraints = YES;
        if (mediaView.superview) {
            [mediaView.superview addSubview:mediaView];
        }
    }
    [self.nativeAdView registerDataObjectWithClickableViews:self.ADView.clickableViews];
    [self.ADView setNeedsLayout];
    [self.ADView layoutIfNeeded];
}

- (BOOL)videoFlag {
    BOOL videoFlag = [((ATNativeADCache*)self.ADView.nativeAd).assets[kATNativeADAssetsContainsVideoFlag] boolValue];
    return videoFlag;
}

- (UIView *)getNetWorkMediaView {
    if (self.videoFlag) {
        if (self.refreshData == NO) {
            LYNativeAdDataObject * dataObject = ((ATNativeADCache*)self.ADView.nativeAd).assets[kATAdAssetsCustomObjectKey];
            [self.nativeAdView refreshData:dataObject];
            self.refreshData = YES;
            if (dataObject.unionType == LYAdSdkUnionTypeADX) {
                self.nativeAdView.mediaView.hidden = NO;
            }
        }
        return self.nativeAdView.mediaView;
    }
    return nil;
}

- (CGFloat)videoPlayTime {
    if (self.videoFlag) {
        return [self.nativeAdView mediaVideoPlayTime];
    }
    return 0;
}

- (CGFloat)videoDuration {
    if (self.videoFlag) {
        return [self.nativeAdView mediaVideoDuration];
    }
    return 0;
}

- (void)muteEnable:(BOOL)flag {
    if (self.videoFlag) {
        [self.nativeAdView mediaVideoMuteEnable:flag];
    }
}

- (void)videoPlay {
    if (self.videoFlag) {
        [self.nativeAdView mediaVideoPlay];
    }
}

- (void)videoPause {
    if (self.videoFlag) {
        [self.nativeAdView mediaVideoPause];
    }
}

@end
