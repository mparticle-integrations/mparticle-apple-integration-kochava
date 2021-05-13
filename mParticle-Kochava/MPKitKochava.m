#import "MPKitKochava.h"
#import "MPKochavaSpatialCoordinate.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import "MPEnums.h"
#if defined(__has_include) && __has_include(<KochavaTracker/KochavaTracker.h>)
#import <KochavaTracker/KochavaTracker.h>
#else
#import "KochavaTracker.h"
#endif
#if defined(__has_include) && __has_include(<KochavaAdNetwork/KochavaAdNetwork.h>)
#import <KochavaAdNetwork/KochavaAdNetwork.h>
#else
#import "KochavaAdNetwork.h"
#endif

NSString *const MPKitKochavaErrorKey = @"mParticle-Kochava Error";
NSString *const MPKitKochavaErrorDomain = @"mParticle-Kochava";
NSString *const MPKitKochavaEnhancedDeeplinkKey = @"mParticle-Kochava Enhanced Deeplink";
NSString *const MPKitKochavaEnhancedDeeplinkDestinationKey = @"destination";
NSString *const MPKitKochavaEnhancedDeeplinkRawKey = @"raw";

NSString *const kvAppId = @"appId";
NSString *const kvCurrency = @"currency";
NSString *const kvUseCustomerId = @"useCustomerId";
NSString *const kvIncludeOtherUserIds = @"passAllOtherUserIdentities";
NSString *const kvRetrieveAttributionData = @"retrieveAttributionData";
NSString *const kvEnableLogging = @"enableLogging";
NSString *const kvLimitAdTracking = @"limitAdTracking";
NSString *const kvLogScreenFormat = @"Viewed %@";
NSString *const kvEcommerce = @"eCommerce";
NSString *const kvEnableATT = @"enableATT";
NSString *const kvEnableATTPrompt = @"enableATTPrompt";
NSString *const kvWaitIntervalATT = @"waitIntervalATT";

// Event type strings
NSString *const kMPEventTypeStringUnknown = @"Unknown";
NSString *const kMPEventTypeStringNavigation = @"Navigation";
NSString *const kMPEventTypeStringLocation = @"Location";
NSString *const kMPEventTypeStringSearch = @"Search";
NSString *const kMPEventTypeStringTransaction = @"Transaction";
NSString *const kMPEventTypeStringUserContent = @"UserContent";
NSString *const kMPEventTypeStringUserPreference = @"UserPreference";
NSString *const kMPEventTypeStringSocial = @"Social";
NSString *const kMPEventTypeStringOther = @"Other";
NSString *const kMPEventTypeStringMedia = @"Media";
NSString *const kMPEventTypeStringProductAddToCart = @"ProductAddToCart";
NSString *const kMPEventTypeStringProductRemoveFromCart = @"ProductRemoveFromCart";
NSString *const kMPEventTypeStringProductCheckout = @"ProductCheckout";
NSString *const kMPEventTypeStringProductCheckoutOption = @"ProductCheckoutOption";
NSString *const kMPEventTypeStringProductClick = @"ProductClick";
NSString *const kMPEventTypeStringProductViewDetail = @"ProductViewDetail";
NSString *const kMPEventTypeStringProductPurchase = @"ProductPurchase";
NSString *const kMPEventTypeStringProductRefund = @"ProductRefund";
NSString *const kMPEventTypeStringPromotionView = @"PromotionView";
NSString *const kMPEventTypeStringPromotionClick = @"PromotionClick";
NSString *const kMPEventTypeStringProductAddToWishlist = @"ProductAddToWishlist";
NSString *const kMPEventTypeStringProductRemoveFromWishlist = @"ProductRemoveFromWishlist";
NSString *const kMPEventTypeStringProductImpression = @"ProductImpression";

@interface MPKitKochava()

@end


@implementation MPKitKochava

+ (NSNumber *)kitCode {
    return @37;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Kochava" className:@"MPKitKochava"];
    [MParticle registerExtension:kitRegister];
}

+ (void)addCustomIdentityLinks:(NSDictionary *)identityLink {
    for (NSString *key in identityLink.allKeys) {
        [KVATracker.shared.identityLink registerWithNameString:key identifierString:identityLink[key]];
    }
}

#pragma mark Accessors and private methods
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
    
    for (NSString *key in identityInfo.allKeys) {
        [KVATracker.shared.identityLink registerWithNameString:key identifierString:identityInfo[key]];
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
    
    for (NSString *key in identityInfo.allKeys) {
        [KVATracker.shared.identityLink registerWithNameString:key identifierString:identityInfo[key]];
    }
}

- (NSError *)errorWithMessage:(NSString *)message {
    NSError *error = [NSError errorWithDomain:MPKitKochavaErrorDomain code:0 userInfo:@{MPKitKochavaErrorKey:message}];
    return error;
}

- (void)retrieveAttributionWithCompletionHandler:(void(^)(NSDictionary *attribution))completionHandler {
    [KVATracker.shared.attribution retrieveResultWithCompletionHandler:^(KVAAttributionResult * _Nonnull attributionResult)
    {
        if (!attributionResult.rawDictionary) {
                [self->_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil attributionData from Kochava"]];
        } else {
            MPAttributionResult *mParticleResult = [[MPAttributionResult alloc] init];
            mParticleResult.linkInfo = attributionResult.rawDictionary;

            [self->_kitApi onAttributionCompleteWithResult:mParticleResult error:nil];
        }
        
        if (completionHandler) {
            completionHandler(attributionResult.rawDictionary);
        }
    }];
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
    
    _configuration = configuration;
    _started = YES;
    
    if (self.configuration[kvEnableATT]) {
        KVATracker.shared.appTrackingTransparency.enabledBool = [self.configuration[kvEnableATT] boolValue] ? TRUE : FALSE;
    }

    if (self.configuration[kvEnableATTPrompt]) {
        KVATracker.shared.appTrackingTransparency.autoRequestTrackingAuthorizationBool = [self.configuration[kvEnableATTPrompt] boolValue] ? TRUE : FALSE;
        if (self.configuration[kvWaitIntervalATT] && [self.configuration[kvEnableATTPrompt] boolValue]) {
            KVATracker.shared.appTrackingTransparency.authorizationStatusWaitTimeInterval = [self.configuration[kvWaitIntervalATT] integerValue];
        }
    }
    
    [KVAAdNetworkProduct.shared register];

    [KVATracker.shared startWithAppGUIDString:self.configuration[kvAppId]];
        
    if (self.configuration[kvLimitAdTracking]) {
        KVATracker.shared.appLimitAdTrackingBool = [self.configuration[kvLimitAdTracking] boolValue] ? TRUE : FALSE;
    }
    
    if (self.configuration[kvEnableLogging]) {
        KVALog.shared.level = [self.configuration[kvEnableLogging] boolValue] ? KVALogLevel.debug : KVALogLevel.never;
    }
    
    if ([configuration[kvUseCustomerId] boolValue] || [configuration[kvIncludeOtherUserIds] boolValue]) {
        [self synchronize];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
    [self retrieveAttributionWithCompletionHandler:nil];
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (id const)providerKitInstance {
    return [self started] ? KVATracker.shared : nil;
}

- (MPKitAPI *)kitApi {
    if (_kitApi == nil) {
        _kitApi = [[MPKitAPI alloc] init];
    }
    
    return _kitApi;
}

- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    KVATracker.shared.appLimitAdTrackingBool = optOut;
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)logBaseEvent:(nonnull MPBaseEvent *)event {
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else if ([event isKindOfClass:[MPCommerceEvent class]]) {
        return [self routeCommerceEvent:(MPCommerceEvent *)event];
    } else {
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeUnavailable];
    }
}

- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    KVAEvent *kochavaEvent = [KVAEvent eventWithType:KVAEventType.custom];
    kochavaEvent.customEventNameString = NSStringFromEventType(event.type);
    kochavaEvent.nameString = event.name;
    kochavaEvent.infoDictionary = event.customAttributes;
    [kochavaEvent send];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess forwardCount:0];
}

- (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
    KVAEvent *kochavaEvent = [KVAEvent eventWithType:KVAEventType.custom];
    kochavaEvent.customEventNameString = NSStringFromEventType(commerceEvent.type);
    NSMutableDictionary *info = [commerceEvent.customAttributes mutableCopy];
    if (info == nil) {
        info = [[NSMutableDictionary alloc] init];
    }
    if (commerceEvent.transactionAttributes.revenue) {
        info[@"RevenueAmount"] = commerceEvent.transactionAttributes.revenue;
    }
    if (commerceEvent.currency) {
        info[@"CurrencyCode"] = commerceEvent.currency;
    }
    kochavaEvent.infoDictionary = [info copy];
    [kochavaEvent send];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess forwardCount:0];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    KVAEvent *kochavaEvent = [KVAEvent eventWithType:KVAEventType.custom];
    kochavaEvent.customEventNameString = [NSString stringWithFormat:@"Viewed %@", event.name];
    kochavaEvent.infoDictionary = event.customAttributes;
    [kochavaEvent send];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess forwardCount:0];
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

- (MPKitExecStatus *)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^ )(NSArray * restorableObjects))restorationHandler {
    NSURL *url = userActivity.webpageURL;
    
    [KVADeeplink processWithURL:url completionHandler:^(KVADeeplink * _Nonnull deeplink) {
        if (!deeplink) {
            [self->_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil deeplink from Kochava"]];
            return;
        }
        
        NSMutableDictionary *innerDictionary = [NSMutableDictionary dictionary];
        if (deeplink.destinationString) {
            innerDictionary[MPKitKochavaEnhancedDeeplinkDestinationKey] = deeplink.destinationString;
        }
        if (deeplink.rawDictionary) {
            innerDictionary[MPKitKochavaEnhancedDeeplinkRawKey] = deeplink.rawDictionary;
        }
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[MPKitKochavaEnhancedDeeplinkKey] = [innerDictionary copy];
        
        MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
        attributionResult.linkInfo = [dictionary copy];
        
        [self->_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
    }];
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setATTStatus:(MPATTAuthorizationStatus)status withATTStatusTimestampMillis:(NSNumber *)attStatusTimestampMillis  API_AVAILABLE(ios(14)){
    KVATracker.shared.appTrackingTransparency.enabledBool = YES;

    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
}

#pragma mark Helper methods

- (FilteredMParticleUser *)currentUser {
    return [[self kitApi] getCurrentUserWithKit:self];
}

@end
