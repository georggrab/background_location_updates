import Flutter
import UIKit
import CoreLocation

func resolveAccuracy(incoming: Int) -> CLLocationAccuracy? {
    switch incoming {
    case 1: return kCLLocationAccuracyBest
    case 2: return kCLLocationAccuracyKilometer
    case 3: return kCLLocationAccuracyHundredMeters
    case 4: return kCLLocationAccuracyThreeKilometers
    case 5: return kCLLocationAccuracyNearestTenMeters
    default: return nil
    }
}

func extractAccuracy(_ call: FlutterMethodCall) -> CLLocationAccuracy? {
    let args = call.arguments as? [Any]
    guard let accuracy = args?[0] as? Int else {
        return nil
    }
    return resolveAccuracy(incoming: accuracy)
}

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
    
    private func handleTrackingStart(accuracy: CLLocationAccuracy) {
        TrackingActivator.persistRequestedAccuracy(requestInterval: accuracy)
        trackingStateChangeHandler?.propagate(trackingStateChange: true)
        initManager(desiredAccuracy: accuracy)
    }
    
    private func handleTrackingStop() {
        trackingStateChangeHandler?.propagate(trackingStateChange: false)
        TrackingActivator.clearRequestedAccuracy()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "trackStart/ios-strategy:significant-location-change":
            guard let desiredAccuracy = extractAccuracy(call) else {
                NSLog("startStart/slc received invalid arguments. Aborting")
                return
            }
            handleTrackingStart(accuracy: desiredAccuracy)
            self.manager?.startMonitoringSignificantLocationChanges()
        case "trackStop/ios-strategy:significant-location-change":
            handleTrackingStop()
            
            self.manager?.stopMonitoringSignificantLocationChanges()
        case "trackStart/ios-strategy:location-change":
            guard let desiredAccuracy = extractAccuracy(call) else {
                NSLog("startStart/slc received invalid arguments. Aborting")
                return
            }
            handleTrackingStart(accuracy: desiredAccuracy)
            self.manager?.startUpdatingLocation()
        case "trackStop/ios-strategy:location-change":
            handleTrackingStop()
            self.manager?.stopUpdatingLocation()
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
        case "getSqliteDatabasePath":
            result(Persistence.getSqliteDbFileName())
        case "revertActiveStrategy":
            handleTrackingStop()
            self.manager?.stopMonitoringSignificantLocationChanges()
            self.manager?.stopUpdatingLocation()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        if (launchOptions[UIApplicationLaunchOptionsKey.location] != nil) {
           let accuracy = TrackingActivator.getRequestedAccuracy()
            if (accuracy == nil) {
                return false
            }
            initManager(desiredAccuracy: accuracy!)
            manager?.startMonitoringSignificantLocationChanges()
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
    
    private func initManager(desiredAccuracy accuracy: CLLocationAccuracy) {
        if (self.manager == nil) {
            self.manager = CLLocationManager()
        }
        self.manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.manager?.delegate = self
        if #available(iOS 9.0, *) {
            if (self.manager?.responds(to: #selector(getter: CLLocationManager.allowsBackgroundLocationUpdates)))! {
                self.manager?.allowsBackgroundLocationUpdates = true
            }
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

