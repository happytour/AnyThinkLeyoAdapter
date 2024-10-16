//
//  LeyouNativeExpressAdRenderer.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import <Foundation/Foundation.h>
#import <AnyThinkNative/AnyThinkNative.h>

#import "LeyouNativeExpressCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface LeyouNativeExpressAdRenderer : ATNativeRenderer
@property(nonatomic, readonly) LeyouNativeExpressCustomEvent *customEvent;
@end

NS_ASSUME_NONNULL_END
