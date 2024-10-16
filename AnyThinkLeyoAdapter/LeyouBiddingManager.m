//
//  LeyouBiddingManager.m
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2022/10/20.
//

#import "LeyouBiddingManager.h"

@interface LeyouBiddingManager ()

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;

@end

@implementation LeyouBiddingManager

+ (instancetype)sharedInstance {
    static LeyouBiddingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LeyouBiddingManager alloc] init];
        sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (LeyouBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.bidingAdStorageAccessor objectForKey:unitID];
    }
}

- (void)removeRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdStorageAccessor removeObjectForKey:unitID];
    }
}

- (void)saveRequestItem:(LeyouBiddingRequest *)request withUnitID:(NSString *)unitID {
    [self.bidingAdStorageAccessor setObject:request forKey:unitID];
}


@end
