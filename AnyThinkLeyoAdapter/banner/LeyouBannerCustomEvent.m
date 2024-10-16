//
//  LeyouBannerCustomEvent.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/25.
//

#import "LeyouBannerCustomEvent.h"
#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@implementation LeyouBannerCustomEvent

- (void)ly_bannerAdViewDidLoad:(LYBannerAdView *)bannerAd {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(bannerAd.eCPM).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:bannerAd];
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
        return;
    }
    [self trackBannerAdLoaded:bannerAd adExtra:nil];
}

- (void)ly_bannerAdViewDidFailToLoad:(LYBannerAdView *)bannerAd error:(NSError *)error {
    if (self.isC2SBiding) {
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:self.slotId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:self.slotId];
        return;
    }
    [self trackBannerAdLoadFailed:error];
}

- (void)ly_bannerAdViewDidExpose:(LYBannerAdView *)bannerAd {
    [self trackBannerAdImpression];
}

- (void)ly_bannerAdViewDidClick:(LYBannerAdView *)bannerAd {
    [self trackBannerAdClick];
}

- (void)ly_bannerAdViewDidClose:(LYBannerAdView *)bannerAd {
    [self trackBannerAdClosed];
}
@end
