//
//  LeyouRewardedVideoCustomEvent.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
@import LYAdSDK;

NS_ASSUME_NONNULL_BEGIN

@interface LeyouRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<LYRewardVideoAdDelegate>
@property(nonatomic, strong)  NSString *slotId;
@end

NS_ASSUME_NONNULL_END
