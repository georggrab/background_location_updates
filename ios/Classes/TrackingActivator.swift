//
//  TrackingActivator.swift
//  background_location_updates
//
//  Created by Grab, Georg (415) on 18.06.18.
//

import Foundation
import UIKit

class TrackingActivator {
    public static let KEY_DESIRED_ACCURACY: String = "io.gjg.backgroundlocationupdates/desired_accuracy"
    public static let USERDEFAULTS_REALM: String = "io.gjg.backgroundlocationupdates"
    
    static func getDefaults() -> UserDefaults {
        var defaults = UserDefaults(suiteName: USERDEFAULTS_REALM)
        if defaults == nil {
            defaults = UserDefaults.standard
        }
        return defaults!
    }
    
    static func persistRequestedAccuracy(requestInterval: Double) {
        getDefaults().set(requestInterval, forKey: TrackingActivator.KEY_DESIRED_ACCURACY)
    }
    
    static func clearRequestedAccuracy() {
        getDefaults().removeObject(forKey: TrackingActivator.KEY_DESIRED_ACCURACY)
    }
    
    static func getRequestedAccuracy() -> Double? {
        let accuracy = getDefaults().double(forKey: TrackingActivator.KEY_DESIRED_ACCURACY)
        if (accuracy == 0) {
            return nil
        }
        return accuracy
    }
    
    static func isTrackingActive() -> Bool {
        return getRequestedAccuracy() != nil
    }
    
}
