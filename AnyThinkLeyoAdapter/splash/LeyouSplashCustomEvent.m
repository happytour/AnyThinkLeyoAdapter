//
//  LeyouSplashCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouSplashCustomEvent.h"

@implementation LeyouSplashCustomEvent

- (void)ly_splashAdDidLoad:(LYSplashAd *)splashAd {
    [self trackSplashAdLoaded:splashAd];
}

- (void)ly_splashAdDidFailToLoad:(LYSplashAd *)splashAd error:(NSError *)error {
    [self trackSplashAdLoadFailed:error];
}

- (void)ly_splashAdDidPresent:(LYSplashAd *)splashAd {
    
}

- (void)ly_splashAdDidExpose:(LYSplashAd *)splashAd {
    [self trackSplashAdShow];
}

- (void)ly_splashAdDidClick:(LYSplashAd *)splashAd {
    [self trackSplashAdClick];
}

- (void)ly_splashAdWillClose:(LYSplashAd *)splashAd {
    
}

- (void)ly_splashAdDidClose:(LYSplashAd *)splashAd {
    [self trackSplashAdClosed];
}

- (void)ly_splashAdLifeTime:(LYSplashAd *)splashAd time:(NSUInteger)time {
    [self trackSplashAdCountdownTime:time];
}

- (void)ly_splashAdDidCloseOtherController:(LYSplashAd *)splashAd {
    [self trackSplashAdDetailClosed];
}

@end
