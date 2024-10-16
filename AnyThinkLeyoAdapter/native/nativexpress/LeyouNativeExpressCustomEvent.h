//
//  LeyouNativeExpressCustomEvent.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import <Foundation/Foundation.h>
#import <AnyThinkNative/AnyThinkNative.h>
@import LYAdSDK;

NS_ASSUME_NONNULL_BEGIN

@interface LeyouNativeExpressCustomEvent : ATNativeADCustomEvent<LYNativeExpressAdDelegate, LYNativeExpressAdRelatedViewDelegate>
@property(nonatomic, strong)  NSString *slotId;
@property(nonatomic, assign)  NSInteger count;
@property(nonatomic, strong) id customObject;
-(NSDictionary *)asset4NativeExpressAdRelatedView:(LYNativeExpressAdRelatedView *) relatedView;
@end

NS_ASSUME_NONNULL_END
