//
//  LeyouRewardedVideoCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouRewardedVideoCustomEvent.h"
#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@implementation LeyouRewardedVideoCustomEvent

- (void)ly_rewardVideoAdDidLoad:(LYRewardVideoAd *)rewardVideoAd {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(rewardVideoAd.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:rewardVideoAd];
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
        return;
    }
    [self trackRewardedVideoAdLoaded:rewardVideoAd adExtra:nil];
}

- (void)ly_rewardVideoAdDidFailToLoad:(LYRewardVideoAd *)rewardVideoAd error:(NSError *)error {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:self.slotId];
        return;
    }
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
    [self trackRewardedVideoAdCloseRewarded:YES extra:[NSDictionary new]];
}

- (void)ly_rewardVideoAdDidPlayFinish:(LYRewardVideoAd *)rewardVideoAd {
    [self trackRewardedVideoAdVideoEnd];
}

- (void)ly_rewardVideoAdDidRewardEffective:(LYRewardVideoAd *)rewardVideoAd trackUid:(NSString *) trackUid {
    [self trackRewardedVideoAdRewarded];
}

@end
