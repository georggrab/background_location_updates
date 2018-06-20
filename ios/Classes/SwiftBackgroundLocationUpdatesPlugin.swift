import Flutter
import UIKit
import CoreLocation

public class SwiftBackgroundLocationUpdatesPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    internal var trackingStateChangeHandler: TrackingStateChangeHandler?
    internal var permissionStateHandler: PermissionStateHandler?
    internal var activityEventChannel : FlutterEventChannel?
    internal var permissionChannel : FlutterEventChannel?
    internal var persistor: Persistence?
    internal var manager: CLLocationManager?
    
    public func register(with registrar: FlutterPluginRegistrar) {
        self.trackingStateChangeHandler = TrackingStateChangeHandler()
        self.permissionStateHandler = PermissionStateHandler()
        
        self.permissionChannel =
            FlutterEventChannel(name: "plugins.gjg.io/background_location_updates/permission_state", binaryMessenger: registrar.messenger())
        self.permissionChannel?.setStreamHandler(self.permissionStateHandler)
        
        self.activityEventChannel =
            FlutterEventChannel(name: "plugins.gjg.io/background_location_updates/tracking_state", binaryMessenger: registrar.messenger())
        self.activityEventChannel?.setStreamHandler(self.trackingStateChangeHandler)

        
        registrar.addApplicationDelegate(self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.gjg.io/background_location_updates", binaryMessenger: registrar.messenger())
        let instance = SwiftBackgroundLocationUpdatesPlugin()
        instance.register(with: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "trackStart/ios-strategy:significant-location-change":
            let arguments = call.arguments as! Array<Any>
            let requestInterval = arguments[0] as! Int
            TrackingActivator.persistRequestInterval(requestInterval: requestInterval)
            trackingStateChangeHandler?.propagate(trackingStateChange: true)
            initManager()
            self.manager?.startUpdatingLocation()
        case "trackStop/ios-strategy:significant-location-change":
            trackingStateChangeHandler?.propagate(trackingStateChange: false)
            TrackingActivator.clearRequestInterval()
        case "trackStart/ios-strategy:location-change":
        case "trackStop/ios-strategy:location-change":
        case "requestPermission":
            NSLog("request")
            if (self.manager == nil) {
                self.manager = CLLocationManager()
            }
            self.manager?.requestAlwaysAuthorization()
        case "getLocationTracesCount":
            ensurePersistor()
            result(persistor?.getAllCount())
        case "getUnreadLocationTracesCount":
            ensurePersistor()
            result(persistor?.getAllUnreadCount())
        case "getLocationTraces":
            ensurePersistor()
            result(persistor?.getAll())
        case "getUnreadLocationTraces":
            ensurePersistor()
            result(persistor?.getUnread())
        case "markAsRead":
            ensurePersistor()
            let args = (call.arguments as! Array<Any>)[0] as! Array<Int>
            let _ = persistor?.markAsRead(args)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        if (launchOptions[UIApplicationLaunchOptionsKey.location] != nil) {
           initManager()
           return true
        } else {
           return false
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!TrackingActivator.isTrackingActive()) {
            return
        }
        ensurePersistor()
        for location in locations {
            self.persistor?.persist(location)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.permissionStateHandler?.propagate(state: PermissionStateHandler.getPermissionEnum(from: status))
    }
    
    private func initManager() {
        if (self.manager == nil) {
            self.manager = CLLocationManager()
            self.manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.manager?.delegate = self
            if #available(iOS 9.0, *) {
                if (self.manager?.responds(to: #selector(getter: CLLocationManager.allowsBackgroundLocationUpdates)))! {
                    self.manager?.allowsBackgroundLocationUpdates = true
                }
            }
            self.manager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    private func ensurePersistor() {
        if (self.persistor == nil) {
            do {
                self.persistor = try Persistence(Persistence.getSqliteDbFileName())
                self.persistor?.createSchema()
            } catch let error as NSError {
                NSLog("Failed creating Persistence. %@", error)
            }
        }
    }
}

