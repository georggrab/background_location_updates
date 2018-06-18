import Flutter
import UIKit
    
public class SwiftBackgroundLocationUpdatesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.gjg.io/background_location_updates", binaryMessenger: registrar.messenger())
    let instance = SwiftBackgroundLocationUpdatesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startTrackingLocation":
        <#code#>
    default:
        <#code#>
    }
    result("iOS " + UIDevice.current.systemVersion)
  }
}

