//
//  LeyouInterstitialCustomEvent.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import <UIKit/UIKit.h>
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
@import LYAdSDK;

NS_ASSUME_NONNULL_BEGIN

@interface LeyouInterstitialCustomEvent : ATInterstitialCustomEvent<LYInterstitialAdDelegate>
@property(nonatomic, strong)  NSString *slotId;
@end

NS_ASSUME_NONNULL_END
