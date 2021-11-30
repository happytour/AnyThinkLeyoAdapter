//
//  LeyouRewardedVideoCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouRewardedVideoCustomEvent.h"

@implementation LeyouRewardedVideoCustomEvent

- (void)ly_rewardVideoAdDidLoad:(LYRewardVideoAd *)rewardVideoAd {
    [self trackRewardedVideoAdLoaded:rewardVideoAd adExtra:nil];
}

- (void)ly_rewardVideoAdDidFailToLoad:(LYRewardVideoAd *)rewardVideoAd error:(NSError *)error {
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)ly_rewardVideoAdDidCache:(LYRewardVideoAd *)rewardVideoAd {
    
}

- (void)ly_rewardVideoAdDidExpose:(LYRewardVideoAd *)rewardVideoAd {
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)ly_rewardVideoAdDidClick:(LYRewardVideoAd *)rewardVideoAd {
    [self trackRewardedVideoAdClick];
}

- (void)ly_rewardVideoAdDidClose:(LYRewardVideoAd *)rewardVideoAd {
    [self trackRewardedVideoAdCloseRewarded:YES];
}

- (void)ly_rewardVideoAdDidPlayFinish:(LYRewardVideoAd *)rewardVideoAd {
    [self trackRewardedVideoAdVideoEnd];
}

- (void)ly_rewardVideoAdDidRewardEffective:(LYRewardVideoAd *)rewardVideoAd trackUid:(NSString *) trackUid {
    [self trackRewardedVideoAdRewarded];
}

@end
