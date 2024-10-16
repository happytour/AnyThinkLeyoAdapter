//
//  LeyouNativeAdRenderer.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import <Foundation/Foundation.h>
#import <AnyThinkNative/AnyThinkNative.h>

#import "LeyouNativeCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface LeyouNativeAdRenderer : ATNativeRenderer
@property(nonatomic, readonly) LeyouNativeCustomEvent *customEvent;
@end

NS_ASSUME_NONNULL_END
