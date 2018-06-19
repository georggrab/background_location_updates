//
//  PermissionStateHandler.swift
//  background_location_updates
//
//  Created by Grab, Georg (415) on 19.06.18.
//

import Foundation
import CoreLocation

class PermissionStateHandler : NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        events(PermissionStateHandler.hasPermission().rawValue)
        self.eventSink = events;
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
       return nil
    }
    
    public func propagate(state: PermissionEnum) {
        self.eventSink?(state.rawValue)
    }
    
    static func getPermissionEnum(from authState: CLAuthorizationStatus) -> PermissionEnum {
        switch (authState) {
        case .authorizedAlways:
            return PermissionEnum.GRANTED
        case .authorizedWhenInUse:
            return PermissionEnum.PARTIAL
        default:
            return PermissionEnum.DENIED
        }

    }
    
    static func hasPermission() -> PermissionEnum {
        return getPermissionEnum(from: CLLocationManager.authorizationStatus())
    }
    
    enum PermissionEnum :Int {
        case GRANTED = 1
        case PARTIAL = 2
        case DENIED = 3
    }
}
