//
//  TrackingActivator.swift
//  background_location_updates
//
//  Created by Grab, Georg (415) on 18.06.18.
//

import Foundation
import UIKit

class TrackingActivator {
    public static let KEY_REQUEST_INTERVAL: String = "requestInterval"
    static func persistRequestInterval(requestInterval: Int) {
        let defaults = UserDefaults.standard
        defaults.set(requestInterval, forKey: TrackingActivator.KEY_REQUEST_INTERVAL)
    }
    
    static func clearRequestInterval() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: TrackingActivator.KEY_REQUEST_INTERVAL)
    }
    
    static func isTrackingActive() -> Bool {
        let defaults = UserDefaults.standard
        let data = defaults.integer(forKey: TrackingActivator.KEY_REQUEST_INTERVAL)
        return data != 0
    }
    
}
