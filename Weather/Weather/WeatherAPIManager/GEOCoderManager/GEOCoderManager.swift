//
//  GEOCoderManager.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation
import CoreLocation

final class GEOCoderManager {
    var geoCoder: CLGeocoder = CLGeocoder()
    
    deinit {
        if geoCoder.isGeocoding {
            geoCoder.cancelGeocode()
        }
    }
    
    func getPosition(forLocation location: CLLocation, completion: @escaping (GEOCoderResult) -> ()) {
        if geoCoder.isGeocoding {
            geoCoder.cancelGeocode()
        }
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let error = error {
                completion(GEOCoderResult.failure(error))
                return
            }
            
            guard let placeMark = placeMarks?.first else { return }
            
            completion(GEOCoderResult.success(placeMark))
        }
    }
}
