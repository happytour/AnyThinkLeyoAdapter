//
//  LeyouBannerCustomEvent.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/25.
//

#import <Foundation/Foundation.h>
#import <AnyThinkBanner/AnyThinkBanner.h>
@import LYAdSDK;

NS_ASSUME_NONNULL_BEGIN

@interface LeyouBannerCustomEvent : ATBannerCustomEvent<LYBannerAdViewDelegate>
@property(nonatomic, strong)  NSString *slotId;
@end

NS_ASSUME_NONNULL_END
