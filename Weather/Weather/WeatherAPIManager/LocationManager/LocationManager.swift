//
//  LocationManager.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManager(_ manager: LocationManager, didReceiveNewLocation location: CLLocation)
    func locationManager(_ manager: LocationManager, didReceiveError error: Error)
}

final class LocationManager: NSObject {
    private let clLocationManager = CLLocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    private var isStartedUpdatingLocation: Bool = false
    private var shouldStopAfterRecievingLocation: Bool = false
    private var locationResult: ((LocationResult) -> ())?
    
    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    override init() {
        super.init()
        
        configureCLLocationManager()
    }
    
    func getLocation(completion: @escaping (LocationResult) -> ()) {
        if let location = clLocationManager.location {
            completion(LocationResult.success(location))
            return
        }
        
        switch authorizationStatus {
        case .denied:
            let error = LocationManagerError(type: .authorizationDenied)
            completion(LocationResult.failure(error))
            return
            
        case .restricted:
            let error = LocationManagerError(type: .authorizationRestricted)
            completion(LocationResult.failure(error))
            return
            
        case .notDetermined:
            fallthrough
            
        default:
            break
        }
        
        if !isStartedUpdatingLocation {
            shouldStopAfterRecievingLocation = true
            start()
        }
        
        locationResult = completion
    }
    
    func start() {
        clLocationManager.startUpdatingLocation()
        isStartedUpdatingLocation = true
    }
    
    func stop() {
        clLocationManager.stopUpdatingLocation()
        isStartedUpdatingLocation = false
    }
    
}

// MARK: - Private
private extension LocationManager {
    func configureCLLocationManager() {
        clLocationManager.delegate = self
        clLocationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if shouldStopAfterRecievingLocation {
            shouldStopAfterRecievingLocation = false
            stop()
        }
        
        guard let location = locations.last else {
            // TODO: Create and show error
            locationResult = nil
            return
        }
        
        locationResult?(LocationResult.success(location))
        locationResult = nil
        
        delegate?.locationManager(self, didReceiveNewLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if shouldStopAfterRecievingLocation {
            shouldStopAfterRecievingLocation = false
            stop()
        }
        
        
        
        locationResult?(LocationResult.failure(error))
        locationResult = nil
        
        delegate?.locationManager(self, didReceiveError: error)
    }
}
