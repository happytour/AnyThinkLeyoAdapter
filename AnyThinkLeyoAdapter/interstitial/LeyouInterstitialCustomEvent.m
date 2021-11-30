//
//  LeyouInterstitialCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouInterstitialCustomEvent.h"

@implementation LeyouInterstitialCustomEvent

- (void)ly_interstitialAdDidLoad:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void)ly_interstitialAdDidFailToLoad:(LYInterstitialAd *)interstitialAd error:(NSError *)error {
    [self trackInterstitialAdLoadFailed:error];
}

- (void)ly_interstitialAdDidExpose:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdShow];
}

- (void)ly_interstitialAdDidClick:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdClick];
}

- (void)ly_interstitialAdDidClose:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdClose];
}

@end
