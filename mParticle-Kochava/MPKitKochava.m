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
NSString *const kvEventTypeStringUnknown = @"unknown";
NSString *const kvEventTypeStringNavigation = @"navigation";
NSString *const kvEventTypeStringLocation = @"location";
NSString *const kvEventTypeStringSearch = @"search";
NSString *const kvEventTypeStringTransaction = @"transaction";
NSString *const kvEventTypeStringUserContent = @"user_content";
NSString *const kvEventTypeStringUserPreference = @"user_preference";
NSString *const kvEventTypeStringSocial = @"social";
NSString *const kvEventTypeStringOther = @"other";
NSString *const kvEventTypeStringProductImpression = @"product_impression";
NSString *const kvEventTypeStringMedia = @"media";

NSString *const kvEventTypeStringProductAddToCart = @"add_to_cart";
NSString *const kvEventTypeStringProductRemoveFromCart = @"remove_from_cart";
NSString *const kvEventTypeStringProductAddToWishlist = @"add_to_wishlist";
NSString *const kvEventTypeStringProductRemoveFromWishlist = @"remove_from_wishlist";
NSString *const kvEventTypeStringProductCheckout = @"checkout";
NSString *const kvEventTypeStringProductCheckoutOption = @"checkout_option";
NSString *const kvEventTypeStringProductClick = @"click";
NSString *const kvEventTypeStringProductViewDetail = @"view_detail";
NSString *const kvEventTypeStringProductPurchase = @"purchase";
NSString *const kvEventTypeStringProductRefund = @"refund";

NSString *const kvEventTypeStringPromotionView = @"view";
NSString *const kvEventTypeStringPromotionClick = @"click";

#define KVNSStringFromEventType( value ) \
( \
@{ \
@( MPEventTypeNavigation )          : kvEventTypeStringNavigation, \
@( MPEventTypeLocation )            : kvEventTypeStringLocation, \
@( MPEventTypeSearch )              : kvEventTypeStringSearch, \
@( MPEventTypeTransaction )         : kvEventTypeStringTransaction, \
@( MPEventTypeUserContent )         : kvEventTypeStringUserContent, \
@( MPEventTypeUserPreference )      : kvEventTypeStringUserPreference, \
@( MPEventTypeSocial )              : kvEventTypeStringSocial, \
@( MPEventTypeOther )               : kvEventTypeStringOther, \
@( MPEventTypeAddToCart )           : kvEventTypeStringProductAddToCart, \
@( MPEventTypeRemoveFromCart )      : kvEventTypeStringProductRemoveFromCart, \
@( MPEventTypeCheckout )            : kvEventTypeStringProductCheckout, \
@( MPEventTypeCheckoutOption )      : kvEventTypeStringProductCheckoutOption, \
@( MPEventTypeClick )               : kvEventTypeStringProductClick, \
@( MPEventTypeViewDetail )          : kvEventTypeStringProductViewDetail, \
@( MPEventTypePurchase )            : kvEventTypeStringProductPurchase, \
@( MPEventTypeRefund )              : kvEventTypeStringProductRefund, \
@( MPEventTypePromotionView )       : kvEventTypeStringPromotionView, \
@( MPEventTypePromotionClick )      : kvEventTypeStringPromotionClick, \
@( MPEventTypeAddToWishlist )       : kvEventTypeStringProductAddToWishlist, \
@( MPEventTypeRemoveFromWishlist )  : kvEventTypeStringProductRemoveFromWishlist, \
@( MPEventTypeImpression )          : kvEventTypeStringProductImpression, \
@( MPEventTypeMedia )               : kvEventTypeStringMedia, \
} \
[ @( value ) ] \
)

#define KVNSStringFromProductAction( value ) \
( \
@{ \
@( MPCommerceEventActionAddToCart )             : kvEventTypeStringProductAddToCart, \
@( MPCommerceEventActionRemoveFromCart )        : kvEventTypeStringProductRemoveFromCart, \
@( MPCommerceEventActionAddToWishList )         : kvEventTypeStringProductAddToWishlist, \
@( MPCommerceEventActionRemoveFromWishlist )    : kvEventTypeStringProductRemoveFromWishlist, \
@( MPCommerceEventActionCheckout )              : kvEventTypeStringProductCheckout, \
@( MPCommerceEventActionCheckoutOptions )       : kvEventTypeStringProductCheckoutOption, \
@( MPCommerceEventActionClick )                 : kvEventTypeStringProductClick, \
@( MPCommerceEventActionViewDetail )            : kvEventTypeStringProductViewDetail, \
@( MPCommerceEventActionPurchase )              : kvEventTypeStringProductPurchase, \
@( MPCommerceEventActionRefund )                : kvEventTypeStringProductRefund, \
} \
[ @( value ) ] \
)

#define KVNSStringFromPromotionAction( value ) \
( \
@{ \
@( MPPromotionActionClick ) : kvEventTypeStringPromotionView, \
@( MPPromotionActionView )  : kvEventTypeStringPromotionClick, \
} \
[ @( value ) ] \
)

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
        [KVAIdentityLink registerWithName:key identifier:identityLink[key]];
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
        [KVAIdentityLink registerWithName:key identifier:identityInfo[key]];
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
        [KVAIdentityLink registerWithName:key identifier:identityInfo[key]];
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
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (void)start {
    if (self.configuration[kvEnableATT]) {
        KVATracker.shared.appTrackingTransparency.enabledBool = [self.configuration[kvEnableATT] boolValue] ? TRUE : FALSE;
    }
    
    if (self.configuration[kvEnableATTPrompt]) {
        KVATracker.shared.appTrackingTransparency.autoRequestTrackingAuthorizationBool = [self.configuration[kvEnableATTPrompt] boolValue] ? TRUE : FALSE;
        if (self.configuration[kvWaitIntervalATT] && [self.configuration[kvEnableATTPrompt] boolValue]) {
            KVATracker.shared.appTrackingTransparency.authorizationStatusWaitTimeInterval = [self.configuration[kvWaitIntervalATT] integerValue];
        }
    }
        
    [KVATracker.shared startWithAppGUIDString:self.configuration[kvAppId]];
    
    if (self.configuration[kvLimitAdTracking]) {
        KVATracker.shared.appLimitAdTracking.boolean = [self.configuration[kvLimitAdTracking] boolValue] ? TRUE : FALSE;
    }
    
    if (self.configuration[kvEnableLogging]) {
        KVALog.shared.level = [self.configuration[kvEnableLogging] boolValue] ? KVALogLevel.debug : KVALogLevel.never;
    }
    
    if ([self.configuration[kvUseCustomerId] boolValue] || [self.configuration[kvIncludeOtherUserIds] boolValue]) {
        [self synchronize];
    }
    
    NSDictionary *userActivityDictionary = self.launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey];
    if (userActivityDictionary == nil)
    {
        [KVADeeplink processWithURL:nil closure_didComplete:^(KVADeeplink * _Nonnull deeplink)
         {
            NSString *destinationString = deeplink.destinationString;
            if (destinationString.length == 0) {
                [self->_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil deeplink from Kochava"]];
                return;
            }
            
            NSMutableDictionary *innerDictionary = [NSMutableDictionary dictionary];
            innerDictionary[MPKitKochavaEnhancedDeeplinkDestinationKey] = destinationString;

            if (deeplink.rawDictionary) {
                innerDictionary[MPKitKochavaEnhancedDeeplinkRawKey] = deeplink.rawDictionary;
            }
            
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            dictionary[MPKitKochavaEnhancedDeeplinkKey] = [innerDictionary copy];
            
            MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
            attributionResult.linkInfo = [dictionary copy];
            
            [self->_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
        }];
    }
    
    self->_started = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
    [self retrieveAttributionWithCompletionHandler:nil];
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
    KVATracker.shared.appLimitAdTracking.boolean = optOut;
    
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
    KVAEvent *kochavaEvent = [[KVAEvent alloc] initWithType:KVAEventType.custom];
    kochavaEvent.customEventName = event.name;
    kochavaEvent.infoDictionary = event.customAttributes;
    [kochavaEvent send];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
    KVAEvent *kochavaEvent = [[KVAEvent alloc] initWithType:KVAEventType.custom];
    NSString *eventName;
    if (commerceEvent.promotionContainer) {
        eventName = [NSString stringWithFormat:@"eCommerce - %@", KVNSStringFromPromotionAction(commerceEvent.promotionContainer.action)];
    } else if (commerceEvent.impressions) {
        eventName = @"eCommerce - Impression";
    } else {
        eventName = [NSString stringWithFormat:@"eCommerce - %@", KVNSStringFromProductAction(commerceEvent.action)];
    }
    kochavaEvent.customEventName = eventName;
    NSMutableDictionary *info = [commerceEvent.customAttributes mutableCopy];
    if (info == nil) {
        info = [[NSMutableDictionary alloc] init];
    }
    if (commerceEvent.transactionAttributes.revenue) {
        info[@"revenue"] = commerceEvent.transactionAttributes.revenue;
    }
    if (commerceEvent.currency) {
        info[@"currency"] = commerceEvent.currency;
    }
    if (commerceEvent.products) {
        NSMutableArray *productArray = [[NSMutableArray alloc] init];
        for (MPProduct *product in commerceEvent.products) {
            [productArray addObject:product.dictionaryRepresentation];
        }
        info[@"products"] = productArray;
    }
    if (commerceEvent.impressions) {
        NSMutableDictionary *impressionDictionary = [[NSMutableDictionary alloc] init];
        [commerceEvent.impressions enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableSet *products, BOOL *stop) {
            NSMutableArray *productArray = [[NSMutableArray alloc] init];
            for (MPProduct *product in commerceEvent.products) {
                [productArray addObject:product.dictionaryRepresentation];
            }
            impressionDictionary[key] = productArray;
        }];
        info[@"impression"] = impressionDictionary;
    }
    if (commerceEvent.promotionContainer) {
        NSMutableArray *promotionArray = [[NSMutableArray alloc] init];
        for (MPProduct *promotion in commerceEvent.promotionContainer.promotions) {
            [promotionArray addObject:promotion.dictionaryRepresentation];
        }
        info[@"promotions"] = promotionArray;
    }
    kochavaEvent.infoDictionary = [info copy];
    [kochavaEvent send];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    KVAEvent *kochavaEvent = [[KVAEvent alloc] initWithType:KVAEventType.custom];
    kochavaEvent.customEventName = [NSString stringWithFormat:@"Viewed %@", event.name];
    kochavaEvent.infoDictionary = event.customAttributes;
    [kochavaEvent send];
    
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceKochava) returnCode:MPKitReturnCodeSuccess];
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
    
    [KVADeeplink processWithURL:url closure_didComplete:^(KVADeeplink * _Nonnull deeplink) {
        NSString *destinationString = deeplink.destinationString;
        if (destinationString.length == 0) {
            [self->_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil deeplink from Kochava"]];
            return;
        }
        
        NSMutableDictionary *innerDictionary = [NSMutableDictionary dictionary];
        innerDictionary[MPKitKochavaEnhancedDeeplinkDestinationKey] = destinationString;

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
