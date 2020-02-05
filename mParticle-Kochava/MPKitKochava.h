#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

extern NSString * _Nonnull const MPKitKochavaErrorKey;
extern NSString * _Nonnull const MPKitKochavaErrorDomain;
extern NSString * _Nonnull const MPKitKochavaEnhancedDeeplinkKey;
extern NSString * _Nonnull const MPKitKochavaEnhancedDeeplinkDestinationKey;
extern NSString * _Nonnull const MPKitKochavaEnhancedDeeplinkRawKey;

@interface MPKitKochava : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;

+ (void)setIdentityLink:(nonnull NSDictionary *)identityLink;

@end
