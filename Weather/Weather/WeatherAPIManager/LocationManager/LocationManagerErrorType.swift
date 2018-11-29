//
//  LocationManagerErrorType.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation

enum LocationManagerErrorType: Int {
    case authorizationDenied = 1
    case authorizationRestricted
}
