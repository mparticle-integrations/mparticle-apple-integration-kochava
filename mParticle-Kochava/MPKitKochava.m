#import "MPKitKochava.h"
#import "MPKochavaSpatialCoordinate.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import "KochavaTracker.h"

NSString *const MPKitKochavaErrorKey = @"mParticle-Kochava Error";
NSString *const MPKitKochavaErrorDomain = @"mParticle-Kochava";

NSString *const kvAppId = @"appId";
NSString *const kvCurrency = @"currency";
NSString *const kvUseCustomerId = @"useCustomerId";
NSString *const kvIncludeOtherUserIds = @"passAllOtherUserIdentities";
NSString *const kvRetrieveAttributionData = @"retrieveAttributionData";
NSString *const kvEnableLogging = @"enableLogging";
NSString *const kvLimitAdTracking = @"limitAdTracking";
NSString *const kvLogScreenFormat = @"Viewed %@";
NSString *const kvEcommerce = @"eCommerce";

static KochavaTracker *kochavaTracker = nil;
static NSDictionary *kochavaIdentityLink = nil;

@interface MPKitKochava() <KochavaTrackerDelegate>

@end


@implementation MPKitKochava

+ (NSNumber *)kitCode {
    return @37;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Kochava" className:@"MPKitKochava"];
    [MParticle registerExtension:kitRegister];
}

+ (void)setIdentityLink:(NSDictionary *)identityLink {
    kochavaIdentityLink = identityLink;
}

#pragma mark Accessors and private methods
- (void)kochavaTracker:(void (^)(KochavaTracker *const kochavaTracker))completionHandler {
    static dispatch_once_t kochavaPredicate;

    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_once(&kochavaPredicate, ^{
            NSMutableDictionary *kochavaInfo = [@{kKVAParamAppGUIDStringKey:self.configuration[kvAppId]
                                                  } mutableCopy];

            if (self.configuration[kvCurrency]) {
                kochavaInfo[@"currency"] = self.configuration[kvCurrency];
            }

            if (self.configuration[kvLimitAdTracking]) {
                kochavaInfo[kKVAParamAppLimitAdTrackingBoolKey] = [self.configuration[kvLimitAdTracking] boolValue] ? @YES : @NO;
            }

            if (self.configuration[kvEnableLogging]) {
                kochavaInfo[kKVAParamLogLevelEnumKey] = [self.configuration[kvEnableLogging] boolValue] ? kKVALogLevelEnumDebug : kKVALogLevelEnumNone;
            }

            id<KochavaTrackerDelegate> delegate = nil;

            if (self.configuration[kvRetrieveAttributionData]) {
                if ([self.configuration[kvRetrieveAttributionData] boolValue]) {
                    kochavaInfo[kKVAParamRetrieveAttributionBoolKey] =  @YES;
                    delegate = self;
                } else {
                    kochavaInfo[kKVAParamRetrieveAttributionBoolKey] =  @NO;
                }
                
            }

            if (kochavaIdentityLink) {
                kochavaInfo[kKVAParamIdentityLinkDictionaryKey] = kochavaIdentityLink;
            }

            CFTypeRef kochavaTrackRef = CFRetain((__bridge CFTypeRef)[[KochavaTracker alloc] initWithParametersDictionary:kochavaInfo delegate:delegate]);
            kochavaTracker = (__bridge KochavaTracker *)kochavaTrackRef;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

                [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            });
        });

        completionHandler(kochavaTracker);
    });
}

- (void)identityLinkCustomerId {
    FilteredMParticleUser *user = [self currentUser];
    if (!user || user.userIdentities.count == 0) {
        return;
    }

    NSMutableDictionary *identityInfo = [[NSMutableDictionary alloc] initWithCapacity:user.userIdentities.count];
    NSString *identityKey;

    NSString *identityValue = user.userIdentities[@(MPUserIdentityCustomerId)];
    if (identityValue) {
        identityKey = @"CustomerId";
        identityInfo[identityKey] = identityValue;
    }

    if (identityInfo.count > 0) {
        [self kochavaTracker:^(KochavaTracker *const kochavaTracker) {
            [kochavaTracker sendIdentityLinkWithDictionary:(NSDictionary *)identityInfo];
        }];
    }
}

- (void)identityLinkOtherUserIds {
    FilteredMParticleUser *user = [self currentUser];
    if (!user.userIdentities || user.userIdentities.count == 0) {
        return;
    }

    NSMutableDictionary *identityInfo = [[NSMutableDictionary alloc] initWithCapacity:user.userIdentities.count];
    NSString *identityKey;
    MPUserIdentity userIdentity;
    for (NSNumber *userIdentityType in user.userIdentities) {
        userIdentity = [userIdentityType integerValue];

        switch (userIdentity) {
            case MPUserIdentityEmail:
                identityKey = @"Email";
                break;

            case MPUserIdentityOther:
                identityKey = @"OtherId";
                break;

            case MPUserIdentityFacebook:
                identityKey = @"Facebook";
                break;

            case MPUserIdentityTwitter:
                identityKey = @"Twitter";
                break;

            case MPUserIdentityGoogle:
                identityKey = @"Google";
                break;

            case MPUserIdentityYahoo:
                identityKey = @"Yahoo";
                break;

            case MPUserIdentityMicrosoft:
                identityKey = @"Microsoft";
                break;

            default:
                continue;
                break;
        }

        NSString *identityValue = user.userIdentities[userIdentityType];
        if (identityValue) {
            identityInfo[identityKey] = identityValue;
        }
    }

    if (identityInfo.count > 0) {
        [self kochavaTracker:^(KochavaTracker *const kochavaTracker) {
            [kochavaTracker sendIdentityLinkWithDictionary:(NSDictionary *)identityInfo];
        }];
    }
}

- (NSError *)errorWithMessage:(NSString *)message {
    NSError *error = [NSError errorWithDomain:MPKitKochavaErrorDomain code:0 userInfo:@{MPKitKochavaErrorKey:message}];
    return error;
}

- (void)retrieveAttributionWithCompletionHandler:(void(^)(NSDictionary *attribution))completionHandler {
    [self kochavaTracker:^(KochavaTracker *const kochavaTracker) {
        NSDictionary *attribution = [kochavaTracker attributionDictionary];
        completionHandler(attribution);
    }];
}

- (void)tracker:(nonnull KochavaTracker *)tracker didRetrieveAttributionDictionary:(nonnull NSDictionary *)attributionDictionary {
    if (!attributionDictionary) {
        [self->_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil attributionData from Kochava"]];
        return;
    }
    
    MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
    attributionResult.linkInfo = attributionDictionary;
    
    [self->_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
}

- (void)synchronize {
    if ([self.configuration[kvUseCustomerId] boolValue]) {
        [self identityLinkCustomerId];
    }

    if ([self.configuration[kvIncludeOtherUserIds] boolValue]) {
        [self identityLinkOtherUserIds];
    }
}

#pragma mark MPKitInstanceProtocol methods
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;

    if (!configuration[kvAppId]) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }

    __weak MPKitKochava *weakSelf = self;
    _configuration = configuration;
    _started = YES;

    [self kochavaTracker:^(KochavaTracker *const kochavaTracker) {
        __strong MPKitKochava *strongSelf = weakSelf;

        if (!strongSelf) {
            return;
        }

        if (kochavaTracker) {
            if ([configuration[kvUseCustomerId] boolValue] || [configuration[kvIncludeOtherUserIds] boolValue]) {
                [strongSelf synchronize];
            }
        }
    }];

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (id const)providerKitInstance {
    return [self started] ? kochavaTracker : nil;
}

- (MPKitAPI *)kitApi {
    if (_kitApi == nil) {
        _kitApi = [[MPKitAPI alloc] init];
    }
    
    return _kitApi;
}

- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    [self kochavaTracker:^(KochavaTracker *const kochavaTracker) {
        [kochavaTracker setAppLimitAdTrackingBool:optOut];
    }];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    FilteredMParticleUser *user = [self currentUser];
    MPKitExecStatus *execStatus = nil;
    if (!identityString || !user) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }

    if (user.userIdentities[@(identityType)] && [user.userIdentities[@(identityType)] isEqual:identityString]) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }

    if (identityType == MPUserIdentityCustomerId) {
        if ([self.configuration[kvUseCustomerId] boolValue]) {
            [self identityLinkCustomerId];
            execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
        }
    } else {
        if ([self.configuration[kvIncludeOtherUserIds] boolValue]) {
            [self identityLinkOtherUserIds];
            execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
        }
    }

    if (!execStatus) {
        execStatus = [[MPKitExecStatus alloc] init];
    }

    return execStatus;
}

#pragma helper methods

- (FilteredMParticleUser *)currentUser {
    return [[self kitApi] getCurrentUserWithKit:self];
}

@end
