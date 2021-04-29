//
//  MainViewController.swift
//  Weather
//
//  Created by Yury Radetsky on 12.04.2021.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var locationNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var currentTempLabel: UILabel!
    @IBOutlet private weak var lowTempLabel: UILabel!
    @IBOutlet private weak var highTempLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let networkService = DataFetcherService()
    private var weatherModel: WeatherModel?
    
    private let backupData = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask)[0].appendingPathComponent("WeatherData.plist")
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupTableView()
        loadBackup()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Setups
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DailyTableViewCell.nib(),
                           forCellReuseIdentifier: DailyTableViewCell.identifier)
        tableView.register(HourlyTableViewCell.nib(),
                           forCellReuseIdentifier: HourlyTableViewCell.identifier)
        tableView.register(InformationTableViewCell.nib(),
                           forCellReuseIdentifier: InformationTableViewCell.identifier)
        tableView.register(DescriptionTableViewCell.nib(),
                           forCellReuseIdentifier: DescriptionTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
    }
    
    //MARK: - Backup
    
    private func saveBackup(data: WeatherModel) {
        do {
            let data = try PropertyListEncoder().encode(data)
            try data.write(to: backupData)
        }
        catch let error {
            print(error)
        }
    }
    
    private func loadBackup(){
        guard let data = try? Data(contentsOf: backupData) else {
            return
        }
        do {
            let backup = try PropertyListDecoder().decode(WeatherModel.self, from: data)
            weatherModel = backup
        } catch let error {
            print(error)
        }
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return WeatherTableViewSection.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = WeatherTableViewSection(sectionIndex: section) else { return 0 }
        
        switch section {
        case .hourly:
            return 1
        case .daily:
            return 7
        case .information:
            return 1
        case .description:
            return descriptionArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = WeatherTableViewSection(sectionIndex: indexPath.section) else { return UITableViewCell() }
        
            switch section {
            case .hourly:
                let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
                if let weatherModel = weatherModel {
                    cell.configure(model: weatherModel)
                }
                return cell
                
            case .daily:
                let cell = tableView.dequeueReusableCell(withIdentifier: DailyTableViewCell.identifier, for: indexPath) as! DailyTableViewCell
                if let weatherModel = weatherModel {
                    cell.configure(model: weatherModel)
                }
                let viewModel = cell.configureTableViewCellViewModelFor(indexPath.row)
                cell.setupCell(viewModel)
                return cell
                
            case .information:
                let cell = tableView.dequeueReusableCell(withIdentifier: InformationTableViewCell.identifier, for: indexPath) as! InformationTableViewCell
                if let weatherModel = weatherModel {
                    cell.configure(model: weatherModel)
                }
                let viewModel = cell.configureTableViewCellViewModelFor(indexPath.row)
                cell.setupCell(viewModel)
                return cell
                
            case .description:
                let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.identifier, for: indexPath) as! DescriptionTableViewCell
                if let weatherModel = weatherModel {
                    cell.configure(model: weatherModel)
                }
                let viewModel = cell.configureTableViewCellViewModelFor(indexPath.row)
                cell.setupCell(viewModel)
                return cell

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = WeatherTableViewSection(sectionIndex: indexPath.section) else { return CGFloat() }
        switch section {
        case .hourly:
            return section.cellHeight
        case .daily:
            return section.cellHeight
        case .information:
            return section.cellHeight
        case .description:
            return section.cellHeight
        }
    }
    
}



// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        networkService.fetchWeatherData(latitude: latitude, longitude: longitude) { [weak self] (weather) in
            guard let self = self,
                  let weather = weather,
                  let currentWeather = weather.current.weather.first,
                  let dailytWeather = weather.daily.first else { return }
            self.locationNameLabel.text = weather.timezone.deletingPrefix()
            self.currentTempLabel.text = String(format: "%.f", weather.current.temp) + "°"
            self.descriptionLabel.text = currentWeather.descriptionWeather.firstCapitalized
            self.lowTempLabel.text = String(format: "%.f", dailytWeather.temp.min) + "°"
            self.highTempLabel.text = String(format: "%.f", dailytWeather.temp.max) + "°"
            self.weatherModel = weather
            self.saveBackup(data: weather)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Can't get location", error)
    }

}
