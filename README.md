## Kochava Kit Integration

This repository contains the [Kochava](https://www.kochava.com) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

## Installation

KochavaTracker 4.0.0 and on is a Swift package.  To install it, simply add this package as a dependency.

In Xcode, see File > Swift Packages > Add Package Dependency ... > and enter the URL for this package repository.

## Integration using CocoaPods

Prior to 4.0.0, KochavaTracker supported CocoaPods.

### Adding the integration

1. Add the kit dependency to your app's Podfile:

    ```
    pod 'mParticle-Kochava', '~> 8.0'
    ```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { Kochava }"` in your Xcode console 

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

### Deeplinking and attribution

Set the property `onAttributionComplete:` on `MParticleOptions` when initializing the mParticle SDK. A copy of your block will be invoked to provide the respective information:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MParticleOptions *options = [MParticleOptions optionsWithKey:@"<<Your app key>>" secret:@"<<Your app secret>>"];
    options.onAttributionComplete = ^void (MPAttributionResult *_Nullable attributionResult, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Attribution fetching for kitCode=%@ failed with error=%@", error.userInfo[mParticleKitInstanceKey], error);
            return;
        }

        if (attributionResult.linkInfo[MPKitKochavaEnhancedDeeplinkKey]) {
            // deeplinking result
            NSDictionary *deeplinkInfo = attributionResult.linkInfo[MPKitKochavaEnhancedDeeplinkKey];
            NSLog(@"Deeplink fetching for kitCode=%@ completed with destination: %@ raw: %@", attributionResult.kitCode, deeplinkInfo[MPKitKochavaEnhancedDeeplinkDestinationKey], deeplinkInfo[MPKitKochavaEnhancedDeeplinkRawKey]);
        } else {
            // attribution result
            NSLog(@"Attribution fetching for kitCode=%@ completed with linkInfo: %@", attributionResult.kitCode, attributionResult.linkInfo);
        }
    };
    [[MParticle sharedInstance] startWithOptions:options];

    return YES;
}
```

### Documentation

[Kochava integration](https://docs.mparticle.com/integrations/kochava/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
