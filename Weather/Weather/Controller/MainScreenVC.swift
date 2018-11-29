//
//  MainScreenVC.swift
//  Weather
//
//  Created by Гоша Бодров on 21.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class MainScreenVC: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var appearentTemperatureLabel: UILabel!
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var weatherManager = APIWeatherManager(apiKey: "94a099511657ac280b6bc926966127f5")
    
    lazy var locationManager = LocationManager()
    lazy var geoCoderManager = GEOCoderManager()
    
    private var currentObjectID: NSManagedObjectID? = nil
    private var currentCityName: String? = nil
    
    private var weatherEntitiesRC: NSFetchedResultsController<WeatherEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWeatherEntitiesRC()
        findLocation()
    }
    

    // MARK: - Target / Action
    @IBAction func findLocation() {
        locationManager.getLocation { [weak self] (result) in
            switch result {
            case .success(let location):
                let coordinates = Coordinates(latitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude)
                
                self?.getLocationInfo(forLocation: location)
                self?.fetchCurrentWeatherData(withCoordinates: coordinates)
                
            case .failure(let error):
                self?.ifLocationServiceEnabled()
                self?.show(locationServicesError: error)
            }
        }
    }
    
    func show(locationServicesError error: Error) {
        guard let locationError = error as? LocationManagerError else {
            print("ERROR!! locationManager-didFailWithError: \(error)")
            
            return
        }
        
        switch locationError.type {
        case .authorizationDenied:
            presentOpenSettingsAlert()
            print("error: authorizationDenied")
            
        case .authorizationRestricted:
            presentOpenSettingsAlert()
            print("error: authorizationRestricted")
        }
    }
    
    // MARK: LocationServiceEnabled
    func ifLocationServiceEnabled(){
        if Reachability.isLocationServiceEnabled() == true {
            // TODO: alert
        } else {
            //You could show an alert like this.
            let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            OperationQueue.main.addOperation {
                self.present(alertController, animated: true, completion:nil)
            }
        }
    }
    
    func presentOpenSettingsAlert() {
        
        let alert = UIAlertController(title: "Уупс! Приложение не знает, где вы находитесь", message: "Перейдтие в  Settings > Privacy чтобы разрешить доступ к текущему местоположению", preferredStyle: .alert)
        if #available(iOS 10.0, *) {
            let goToSetting = UIAlertAction(title: "Настройки", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            alert.addAction(goToSetting)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    private func configureWeatherEntitiesRC() {
        if let context = CoreDataStorage.instance.weatherPersistedContext {
            
            let fetchRequest = NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "responseDate", ascending: false)]
            weatherEntitiesRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            weatherEntitiesRC?.delegate = self
            try? weatherEntitiesRC?.performFetch()
        }
        
    }
    
    // MARK: fetch Weather
    func fetchCurrentWeatherData(withCoordinates coordinates: Coordinates){
        weatherManager.fetchCurrentWeatherWith(coordinates: coordinates) { (result) in
            switch result {
            case .Success(let currentWeather):
                if let city = self.currentCityName {
                    currentWeather.city = city
                    try? currentWeather.managedObjectContext?.save()
                }
                
                self.updateUIWith(currentWeather: currentWeather)
            case .Failure(let error as NSError):
                
                let alertController = UIAlertController(title: "Unable to get data ", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            default: break
            }
        }
    }
    
    // MARK: Fetch City
    func getLocationInfo(forLocation location: CLLocation) {
        currentCityName = nil
        geoCoderManager.getPosition(forLocation: location) { (result) in
            switch result {
            case .success(let placemark):
                if let dictionary = placemark.addressDictionary {
                    print(dictionary)
                    if let city = dictionary["City"] as? String {
                        self.setCityToCurrentWeatherEntity(city)
                        self.currentCityName = city
                        self.updateLocatonLabel(city: city)
                    }
                }
                print(placemark.country ?? "")
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: UpdateUI
    
    func updateLocatonLabel(city: String){
        self.locationLabel.text = city
    }
    
    func updateUIWith(currentWeather: WeatherEntity) {
        self.imageView.image = currentWeather.icon
        self.pressureLabel.text = currentWeather.pressureString
        self.temperatureLabel.text = currentWeather.temperatureString
        self.appearentTemperatureLabel.text = currentWeather.appearentTemperatureString
        self.humidityLabel.text = currentWeather.humidityString
        
        currentObjectID = currentWeather.objectID
    }
    
    // MARK: - Other
    
    private func setCityToCurrentWeatherEntity(_ city: String) {
        if let currentObjectID = currentObjectID, let context = CoreDataStorage.instance.weatherPersistedContext {
            context.perform {
                if let currentEntity = try? context.existingObject(with: currentObjectID) as? WeatherEntity {
                    currentEntity?.city = city
                    try? context.save()
                }
            }
        }
    }
}

extension MainScreenVC: UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WeatherInfoTableViewCell
        let weatherEntity = weatherEntitiesRC.fetchedObjects![indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        cell.cityLabel.text = weatherEntity.city
        if let responseDate = weatherEntity.responseDate {
            cell.dateLabel.text = df.string(from: responseDate)
        }
        cell.humidityLabel.text = weatherEntity.humidityString
        cell.temperatureLabel.text = weatherEntity.temperatureString
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherEntitiesRC?.fetchedObjects?.count ?? 0
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
