//
//  WeatherEntity.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import CoreData
import UIKit

class WeatherEntity: NSManagedObject {
    
    @NSManaged var apparentTemperature: Double
    @NSManaged var city: String?
    @NSManaged var humidity: Double
    @NSManaged var iconName: String?
    @NSManaged var pressure: Double
    @NSManaged var responseDate: Date?
    @NSManaged var temperature: Double
    
    init?(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, fromJSON JSON: [String: Any]) {
        guard let temperature = JSON["temperature"] as? Double,
            let apparentTemperature = JSON["apparentTemperature"] as? Double,
            let humidity = JSON["humidity"] as? Double,
            let pressure = JSON["pressure"] as? Double,
            let iconName = JSON["icon"] as? String else {
                return nil
        }
        super.init(entity: entity, insertInto: context)
        
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.humidity = humidity
        self.pressure = pressure
        self.iconName = iconName
        self.responseDate = Date()
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

extension WeatherEntity {
    
    var icon: UIImage {
        return WeatherIconManager(rawValue: iconName ?? "").image
    }
    
    var pressureString: String {
        return "\(Int(pressure * 0.750062)) mm"
    }
    
    var humidityString: String {
        return "\(Int(humidity * 100)) %"
    }
    
    var temperatureString: String {
        return "\(Int(5 / 9 * (temperature - 32)))˚C"
    }
    
    var appearentTemperatureString: String {
        return "Feels like: \(Int(5 / 9 * (apparentTemperature - 32)))˚C"
    }
    
}
