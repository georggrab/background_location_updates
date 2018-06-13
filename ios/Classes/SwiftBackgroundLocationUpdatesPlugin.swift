import Flutter
import UIKit
    
public class SwiftBackgroundLocationUpdatesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "background_location_updates", binaryMessenger: registrar.messenger())
    let instance = SwiftBackgroundLocationUpdatesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
