//
//  Reachability.swift
//  Weather
//
//  Created by Гоша Бодров on 28.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation
import CoreLocation

open class Reachability {
    class func isLocationServiceEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                print("Something wrong with Location services")
                return false
            }
        } else {
            print("Location services are not enabled")
            return false
        }
    }
}
