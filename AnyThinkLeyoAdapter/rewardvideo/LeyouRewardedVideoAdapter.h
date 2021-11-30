//
//  LeyouRewardedVideoAdapter.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeyouRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

NS_ASSUME_NONNULL_END
