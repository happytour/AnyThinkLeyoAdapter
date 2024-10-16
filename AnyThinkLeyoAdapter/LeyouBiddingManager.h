//
//  LeyouBiddingManager.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2022/10/20.
//

#import <Foundation/Foundation.h>

#import "LeyouBiddingRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface LeyouBiddingManager : NSObject

+ (instancetype)sharedInstance;

- (void)saveRequestItem:(LeyouBiddingRequest *)request withUnitID:(NSString *)unitID;

- (LeyouBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItemWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
