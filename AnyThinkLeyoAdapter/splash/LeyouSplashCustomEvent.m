//
//  LeyouSplashCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouSplashCustomEvent.h"
#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@implementation LeyouSplashCustomEvent

- (void)ly_splashAdDidLoad:(LYSplashAd *)splashAd {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(splashAd.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:splashAd];
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
        return;
    }
    [self trackSplashAdLoaded:splashAd];
}

- (void)ly_splashAdDidFailToLoad:(LYSplashAd *)splashAd error:(NSError *)error {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:self.slotId];
        return;
    }
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
    [self trackSplashAdClosed:nil];
}

- (void)ly_splashAdLifeTime:(LYSplashAd *)splashAd time:(NSUInteger)time {
    [self trackSplashAdCountdownTime:time];
}

- (void)ly_splashAdDidCloseOtherController:(LYSplashAd *)splashAd {
    [self trackSplashAdDetailClosed];
}

@end
