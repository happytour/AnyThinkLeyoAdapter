//
//  LeyouRewardedVideoAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouRewardedVideoAdapter.h"
#import "LeyouRewardedVideoCustomEvent.h"
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>

@interface LeyouRewardedVideoAdapter()
@property(nonatomic, readonly) LeyouRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) LYRewardVideoAd *rewardVideoAd;
@end

@implementation LeyouRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return YES;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    LeyouRewardedVideoCustomEvent *customEvent = (LeyouRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((LYRewardVideoAd *)rewardedVideo.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [LYAdSDKConfig initAppId:serverInfo[@"app_id"]];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[LeyouRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    
    NSDictionary *extra = localInfo;
    if (extra[kATAdLoadingExtraUserIDKey] != nil) {
        NSString *userId = extra[kATAdLoadingExtraUserIDKey];
        [LYAdSDKConfig setUserId:userId];
    }
    if (extra[kATAdLoadingExtraMediaExtraKey] != nil) {
        NSString *ext = extra[kATAdLoadingExtraMediaExtraKey];
        _rewardVideoAd = [[LYRewardVideoAd alloc] initWithSlotId:serverInfo[@"slot_id"] extra:ext];
    } else {
        _rewardVideoAd = [[LYRewardVideoAd alloc] initWithSlotId:serverInfo[@"slot_id"]];
    }
    _rewardVideoAd.delegate = _customEvent;
    [_rewardVideoAd loadAd];
}

@end
