//
//  LocationManagerError.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation

class LocationManagerError: Error {
    let type: LocationManagerErrorType
    let message: String?
    
    var code: Int {
        return type.rawValue
    }
    
    init(type: LocationManagerErrorType, message: String? = nil) {
        self.type = type
        self.message = message
    }
}
