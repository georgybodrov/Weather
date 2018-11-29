//
//  APIWeatherManager.swift
//  Weather
//
//  Created by Гоша Бодров on 22.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import CoreData

struct Coordinates {
    let latitude: Double
    let longitude: Double
}

// Creat full URL
enum ForecastType: FinalURLPoint {
    case Current(apiKey: String, coordinates: Coordinates)
    
    var baseURL: URL {
        return URL(string: "https://api.forecast.io")!
    }
    
    var path: String {
        switch self {
        case .Current(let apiKey, let coordinates):
            return "/forecast/\(apiKey)/\(coordinates.latitude),\(coordinates.longitude)"
        }
    }
    
    var request: URLRequest {
        let url = URL(string: path, relativeTo: baseURL)
        return URLRequest(url: url!)
    }
}

final class APIWeatherManager: APIManager {
    var sessionConfiguration: URLSessionConfiguration
    
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    } ()
    
    let apiKey: String
    
    init(sessionConfiguration: URLSessionConfiguration, apiKey: String) {
        self.sessionConfiguration = sessionConfiguration
        self.apiKey = apiKey
    }
    
    convenience init(apiKey: String) {
        self.init(sessionConfiguration: URLSessionConfiguration.default, apiKey: apiKey)
    }
    
    //MARK: data loading
    func fetchCurrentWeatherWith(coordinates: Coordinates, completionHandler: @escaping (APIResult<WeatherEntity>) -> Void) {
        let request = ForecastType.Current(apiKey: self.apiKey, coordinates: coordinates).request
        
        fetch(request: request, parse: { (json) -> WeatherEntity? in
            if let dictionary = json["currently"] as? [String: AnyObject], let context = CoreDataStorage.instance.weatherPersistedContext {
               
                let weather = WeatherEntity(entity: NSEntityDescription.entity(forEntityName: "WeatherEntity", in: context)!, insertInto: context, fromJSON: dictionary)
                try? context.save()
                return weather
            } else {
                return nil
            }
            
        }, completionHandler: completionHandler)
    }
}
