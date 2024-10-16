//
//  LeyouInterstitialCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouInterstitialCustomEvent.h"
#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@implementation LeyouInterstitialCustomEvent

- (void)ly_interstitialAdDidLoad:(LYInterstitialAd *)interstitialAd {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(interstitialAd.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:interstitialAd];
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
        return;
    }
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void)ly_interstitialAdDidFailToLoad:(LYInterstitialAd *)interstitialAd error:(NSError *)error {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:self.slotId];
        return;
    }
    [self trackInterstitialAdLoadFailed:error];
}

- (void)ly_interstitialAdDidExpose:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdShow];
}

- (void)ly_interstitialAdDidClick:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdClick];
}

- (void)ly_interstitialAdDidClose:(LYInterstitialAd *)interstitialAd {
    [self trackInterstitialAdClose:nil];
}

@end
