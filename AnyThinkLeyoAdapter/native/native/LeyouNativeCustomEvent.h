//
//  LeyouNativeCustomEvent.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import <Foundation/Foundation.h>
#import <AnyThinkNative/AnyThinkNative.h>
@import LYAdSDK;

NS_ASSUME_NONNULL_BEGIN

@interface LeyouNativeCustomEvent : ATNativeADCustomEvent<LYNativeAdDelegate, LYNativeAdViewDelegate>
@property(nonatomic, strong)  NSString *slotId;
@property(nonatomic, assign)  NSInteger count;
@property(nonatomic, strong) id customObject;
-(NSDictionary *)asset4NativeAdDataObjec:(LYNativeAdDataObject *) dataObject;
@end

NS_ASSUME_NONNULL_END
