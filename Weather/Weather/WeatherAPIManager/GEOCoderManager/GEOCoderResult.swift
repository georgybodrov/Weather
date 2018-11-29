//
//  GEOCoderResult.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation
import CoreLocation

enum GEOCoderResult {
    case success(CLPlacemark)
    case failure(Error)
}
