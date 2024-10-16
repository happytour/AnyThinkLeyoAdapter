//
//  LeyouSplashAdapter.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import "LeyouSplashAdapter.h"
#import "LeyouSplashCustomEvent.h"
#import <AnyThinkSplash/AnyThinkSplash.h>

#import "LeyouBiddingRequest.h"
#import "LeyouBiddingManager.h"

@interface LeyouSplashAdapter()
@property(nonatomic, readonly, strong) LeyouSplashCustomEvent *customEvent;
@property(nonatomic, readonly, strong) LYSplashAd *splashAd;
@end

@implementation LeyouSplashAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [(LYSplashAd *)customObject isValid];
}

+(void) showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    splash.customEvent.delegate = delegate;
    NSDictionary *extra = localInfo;
    UIWindow *window = extra[kATSplashExtraWindowKey];
    [(LYSplashAd *)splash.customObject showAdInWindow:window];
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
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    if (bidId) {
        NSString * slotId = serverInfo[@"slot_id"];
        LeyouBiddingRequest *request = [[LeyouBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
        if (request == nil) {
            _customEvent = [[LeyouSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"request nil."}];
            [_customEvent trackSplashAdLoadFailed:error];
            return;
        }
        _customEvent = (LeyouSplashCustomEvent *)request.customEvent;
        _customEvent.requestCompletionBlock = completion;
        if (request.customObject) {
            _splashAd = request.customObject;
            [_customEvent trackSplashAdLoaded:_splashAd];
        } else {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"request.customObject nil."}];
            [_customEvent trackSplashAdLoadFailed:error];
        }
        [[LeyouBiddingManager sharedInstance] removeRequestItemWithUnitID:slotId];
        return;
    }
    _customEvent = [[LeyouSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * slotId = serverInfo[@"slot_id"];
        
        UIView *containerView = extra[kATSplashExtraContainerViewKey];
        CGRect frame = [UIScreen mainScreen].bounds;
        CGSize bottomSize = containerView ? containerView.frame.size : CGSizeZero;
        CGRect splashFrame = CGRectMake(0, 0, frame.size.width, frame.size.height - bottomSize.height);
        
        self->_splashAd = [[LYSplashAd alloc] initWithFrame:splashFrame slotId:slotId];
        UIViewController * vc = extra[kATSplashExtraInViewControllerKey];
        if (vc) {
            self->_splashAd.viewController = vc;
        }
        self->_splashAd.customBottomView = containerView;
        self->_splashAd.delegate = self->_customEvent;
        [self->_splashAd loadAd];
    });
}

+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    [LYAdSDKConfig initAppId:info[@"app_id"]];
    
    LeyouSplashCustomEvent *customEvent = [[LeyouSplashCustomEvent alloc] initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    
    LeyouBiddingRequest *request = [LeyouBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"slot_id"];
    request.extraInfo = info;
    request.customEvent = customEvent;
    
    customEvent.slotId = request.unitID;
    
    [[LeyouBiddingManager sharedInstance] saveRequestItem:request withUnitID:request.unitID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * slotId = request.unitID;
        
        UIView *containerView = request.extraInfo[kATSplashExtraContainerViewKey];
        CGRect frame = [UIScreen mainScreen].bounds;
        CGSize bottomSize = containerView ? containerView.frame.size : CGSizeZero;
        CGRect splashFrame = CGRectMake(0, 0, frame.size.width, frame.size.height - bottomSize.height);
        
        LYSplashAd *splashAd = [[LYSplashAd alloc] initWithFrame:splashFrame slotId:slotId];
        UIViewController * vc = request.extraInfo[kATSplashExtraInViewControllerKey];
        if (vc) {
            splashAd.viewController = vc;
        }
        splashAd.customBottomView = containerView;
        splashAd.delegate = customEvent;
        [splashAd loadAd];
        request.customObject = splashAd;
    });
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    LYSplashAd *splashAd = (LYSplashAd *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(splashAd.eCPM) forKey:LY_M_W_E_COST_PRICE];
    [info setObject:@(price.integerValue) forKey:LY_M_W_H_LOSS_PRICE];
    [splashAd sendWinNotificationWithInfo:info];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    LYSplashAd *splashAd = (LYSplashAd *)customObject;
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setObject:@(price.integerValue) forKey:LY_M_L_WIN_PRICE];
    LYAdBiddingLossReason reason = LYAdBiddingLossReasonOther;
    if (lossType == ATBiddingLossWithLowPriceInNormal || lossType == ATBiddingLossWithLowPriceInHB || lossType == ATBiddingLossWithFloorFilter) {
        reason = LYAdBiddingLossReasonLowPrice;
    } else if (lossType == ATBiddingLossWithBiddingTimeOut) {
        reason = LYAdBiddingLossReasonLoadTimeout;
    } else if (lossType == ATBiddingLossWithExpire) {
        reason = LYAdBiddingLossReasonCacheInvalid;
    }
    [info setObject:@(reason) forKey:LY_M_L_LOSS_REASON];
    [info setObject:@(YES) forKey:LY_M_ADN_IS_BID];
    [info setObject:@(LYAdAdnTypeOther) forKey:LY_M_ADN_TYPE];
    [info setObject:@"other" forKey:LY_M_ADN_NAME];
    [splashAd sendLossNotificationWithInfo:info];
}

@end
