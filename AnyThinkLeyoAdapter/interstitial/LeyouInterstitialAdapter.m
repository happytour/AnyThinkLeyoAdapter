//
//  LeyouInterstitialAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouInterstitialAdapter.h"
#import "LeyouInterstitialCustomEvent.h"
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>

@interface LeyouInterstitialAdapter()
@property(nonatomic, readonly) LYInterstitialAd *interstitial;
@property(nonatomic, readonly) LeyouInterstitialCustomEvent *customEvent;
@end

@implementation LeyouInterstitialAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return YES;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    //Here for full screen video ad, we also use id<ATWMInterstitialAd>, for the presenting methods are the same.
    interstitial.customEvent.delegate = delegate;
    [(LYInterstitialAd *)interstitial.customObject showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [LYAdSDKConfig initAppId:serverInfo[@"app_id"]];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    _customEvent = [[LeyouInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    
    CGSize adSize = [serverInfo[@"size"] respondsToSelector:@selector(CGSizeValue)] ? [serverInfo[@"size"] CGSizeValue] : CGSizeMake(300.0f, 300.0f);
    _interstitial = [[LYInterstitialAd alloc] initWithSlotId:serverInfo[@"slot_id"] adSize:adSize];
    _interstitial.delegate = _customEvent;
    [_interstitial loadAd];
}

@end
