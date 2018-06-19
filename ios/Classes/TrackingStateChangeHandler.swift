//
//  TrackingStateChangeHandler.swift
//
//  Created by Grab, Georg (415) on 18.06.18.
//

import Foundation
import Flutter

class TrackingStateChangeHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
       self.eventSink = events
       events(TrackingActivator.isTrackingActive())
       return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    public func propagate(trackingStateChange change: Bool) {
        self.eventSink?(change)
    }
}
