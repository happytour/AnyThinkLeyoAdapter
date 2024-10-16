//
//  LeyouNativeExpressAdAdapter.h
//  AnyThinkLeyoAdapter
//
//  Created by laole918 on 2024/9/26.
//

#import <Foundation/Foundation.h>
#import <AnyThinkNative/AnyThinkNative.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeyouNativeExpressAdAdapter : NSObject
- (void)loadADWithInfo:(nonnull NSDictionary *)serverInfo localInfo:(nonnull NSDictionary *)localInfo completion:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion;
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion;
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo;
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo;
@end

NS_ASSUME_NONNULL_END
