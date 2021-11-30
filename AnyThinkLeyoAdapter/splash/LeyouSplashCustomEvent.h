//
//  LeyouSplashCustomEvent.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import <UIKit/UIKit.h>
#import <AnyThinkSplash/AnyThinkSplash.h>
@import LYAdSDK;

NS_ASSUME_NONNULL_BEGIN

@interface LeyouSplashCustomEvent : ATSplashCustomEvent<LYSplashAdDelegate>
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic, weak) LYSplashAd *splashAd;
@property(nonatomic) NSDate *expireDate;
@end

NS_ASSUME_NONNULL_END
