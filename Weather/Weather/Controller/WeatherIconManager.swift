//
//  WeatherIconManager.swift
//  Weather
//
//  Created by Гоша Бодров on 21.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation
import UIKit

// On the server, "icon" field contains several values. WeatherIconManager handle values
enum WeatherIconManager: String {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain = "rain"
    case snow = "snow"
    case sleet = "sleet"
    case wind = "wind"
    case fog = "fog"
    case cloudy = "cloudy"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case unpredictedIcon = "unpredicted-icon"
    
    init(rawValue: String) {
        switch rawValue {
        case "clear-day": self = .clearDay
        case "clear-night": self = .clearNight
        case "rain": self = .rain
        case "snow": self = .snow
        case "sleet": self = .sleet
        case "wind": self = .wind
        case "fog": self = .fog
        case "cloudy": self = .cloudy
        case "partly-cloudy-day": self = .partlyCloudyDay
        case "partly-cloudy-night": self = .partlyCloudyNight
        default: self = .unpredictedIcon
            
        }
    }
}

extension WeatherIconManager {
    var image: UIImage {
        switch self {
        case .clearDay: return UIImage(named: "clear-day")!
        case .clearNight: return UIImage(named: "clear-night")!
        case .rain: return UIImage(named: "rain")!
        case .snow: return UIImage(named: "snow")!
        case .sleet: return UIImage(named: "sleet")!
        case .wind: return UIImage(named: "wind")!
        case .fog: return UIImage(named: "fog")!
        case .cloudy: return UIImage(named: "cloudy")!
        case .partlyCloudyDay: return UIImage(named: "partly-cloudy-day")!
        case .partlyCloudyNight: return UIImage(named: "partly-cloudy-night")!
        case .unpredictedIcon: return UIImage(named: "unpredicted-icon")!
        }
    }
}
