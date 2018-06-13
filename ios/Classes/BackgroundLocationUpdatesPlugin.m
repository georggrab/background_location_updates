#import "BackgroundLocationUpdatesPlugin.h"
#import <background_location_updates/background_location_updates-Swift.h>

@implementation BackgroundLocationUpdatesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBackgroundLocationUpdatesPlugin registerWithRegistrar:registrar];
}
@end
