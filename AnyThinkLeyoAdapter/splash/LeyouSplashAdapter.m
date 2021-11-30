//
//  LeyouSplashAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouSplashAdapter.h"
#import "LeyouSplashCustomEvent.h"
#import <AnyThinkSplash/AnyThinkSplash.h>

@interface LeyouSplashAdapter()
@property(nonatomic, readonly) LeyouSplashCustomEvent *customEvent;
@property(nonatomic, readonly) LYSplashAd *splashAd;
@end

@implementation LeyouSplashAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return YES;
}

+(void) showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    splash.customEvent.delegate = delegate;
    NSDictionary *extra = localInfo;
    UIWindow *window = extra[kATSplashExtraWindowKey];
    UIView * containerView = ((LeyouSplashCustomEvent *)splash.customEvent).containerView;
    if (containerView) {
        [(LYSplashAd *)splash.customObject showAdInWindow:window withBottomView:containerView];
    } else {
        [(LYSplashAd *)splash.customObject showAdInWindow:window];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [LYAdSDKConfig initAppId:serverInfo[@"app_id"]];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extra = localInfo;
    
    _customEvent = [[LeyouSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;

    NSString * slotId = serverInfo[@"slot_id"];
    CGSize adSize = extra[kATAdLoadingExtraSplashAdSizeKey] ? [extra[kATAdLoadingExtraSplashAdSizeKey] CGSizeValue] : CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    CGRect frame = CGRectMake(.0f, .0f, adSize.width, adSize.height);
    UIViewController * vc = extra[kATSplashExtraRootViewControllerKey];
    if (vc) {
        self->_splashAd = [[LYSplashAd alloc] initWithFrame:frame slotId:slotId viewController:vc];
    } else {
        self->_splashAd = [[LYSplashAd alloc] initWithFrame:frame slotId:slotId];
    }
    UIView *containerView = extra[kATSplashExtraContainerViewKey];
    self->_customEvent.containerView = containerView;
    self->_splashAd.delegate = self->_customEvent;
    self->_customEvent.splashAd = self->_splashAd;
    [self->_splashAd loadAd];
}

@end
