//
//  MainViewController.swift
//  yandexWeather
//
//  Created by Георгий iMac on 20.12.2020.
//

import UIKit
import Alamofire
import SVGKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var cityName           : UILabel!
    @IBOutlet weak var currentTemperature : UILabel!
    @IBOutlet weak var currentWeatherImage: CustomImageView!
    @IBOutlet weak var forecastsTableView : UITableView!
    @IBOutlet weak var cityCellsCollection: UICollectionView!
    
    var cityData         : CityData!
    var cityDataArray    : [CityData] = []
    var indexCurrentCity = SelectedCityID.shared.getSelectedCityID()
    var cityCollection   : Results<WeatherData>!
    var tumbler = 0
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        let addCityVC = segue.source as! AddCityViewController
        addCity(cityName: addCityVC.textData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCityVC" {
            let _ = segue.destination as! AddCityViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityCollection = realm.objects(WeatherData.self).sorted(byKeyPath: "id")
        
        forecastsTableView.delegate = self
        forecastsTableView.dataSource = self
        forecastsTableView.tableFooterView = UIView()
        
        cityCellsCollection.delegate = self
        cityCellsCollection.dataSource = self

        print( "count of realm.objects(WeatherData.self).count: ",cityCollection.count)
        if cityCollection.count != 0 {
            indexCurrentCity = SelectedCityID.shared.getSelectedCityID()
            let currentWeather = cityCollection[indexCurrentCity]
            currentTemperature.text = String(currentWeather.currentTemperature)+" °C"
            currentWeatherImage.loadImageUsingUrlString(urlString: currentWeather.currentWeatherimageURL)
            cityName.text = currentWeather.cityName
            addCity(cityName: currentWeather.cityName)
        } else {
            currentTemperature.text = "_ _ °C"
            currentWeatherImage.loadImageUsingUrlString(urlString: "https://yastatic.net/weather/i/icons/blueye/color/svg/ovc.svg")
            cityName.text = "Привет!"
            }
        cityCellsCollection.reloadData()
        
        let nibTable = UINib.init(nibName: "CustomTableViewCell", bundle: nil)
        forecastsTableView.register(nibTable, forCellReuseIdentifier: "customCell")
        
        let nibCollection = UINib.init(nibName: "CustomCollectionViewCell", bundle: nil)
        cityCellsCollection.register(nibCollection, forCellWithReuseIdentifier: "customCollectionCell")
        
        let nibPlus = UINib.init(nibName: "AddCityViewCell", bundle: nil)
        cityCellsCollection.register(nibPlus, forCellWithReuseIdentifier: "addCityCell")
    }
}
 

//work with protocol for cityData
extension MainViewController: CityDataDelegate {
    func updateTop (cityName: String, haveData: Bool) -> () {
    if haveData {
        cityCollection = realm.objects(WeatherData.self).sorted(byKeyPath: "id")
        if tumbler == cityCollection.count {
        indexCurrentCity = SelectedCityID.shared.getSelectedCityID()
        } else { indexCurrentCity = cityCollection.count-1 }
         let  currentTemp = cityCollection[indexCurrentCity].currentTemperature
         let     cityName = cityCollection[indexCurrentCity].cityName
         let currentImage = cityCollection[indexCurrentCity].currentWeatherimageURL
        currentTemperature.text = String(currentTemp)+" °C"
        currentWeatherImage.loadImageUsingUrlString(urlString: currentImage )
        self.cityName.text = cityName
        forecastsTableView.reloadData()
        cityCellsCollection.reloadData()
    } else {
        self.showAlert(title: "Крупная ошибка", message: "города с именем \(cityName) нет")
        }
    }
}


//work with tableView
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = realm.objects(WeatherData.self).last?.forecasts.count else {return 0}
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell
        let imageURL   = cityCollection[indexCurrentCity].forecasts[indexPath.row].weatherImageURL
        let weekDay    = cityCollection[indexCurrentCity].forecasts[indexPath.row].weekDay
        let condition  = cityCollection[indexCurrentCity].forecasts[indexPath.row].condition
        let dayTemp    = cityCollection[indexCurrentCity].forecasts[indexPath.row].dayTemperature
        let nightTemp  = cityCollection[indexCurrentCity].forecasts[indexPath.row].nightTemperature
        cell?.commonInit(imageURL : imageURL,
                         weekDay  : weekDay,
                         condition: condition,
                         dayTemp  : dayTemp,
                         nightTemp: nightTemp)
        return cell!
    }
        
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


//work with collectionView
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _ = cityCollection else {return 1}
        return cityCollection.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row != 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell", for: indexPath) as! CustomCollectionViewCell
        let savedData = cityCollection[indexPath.row-1]
            cell.commonInit(    iconURL:        savedData.currentWeatherimageURL
                              ,cityName:        savedData.cityName
                           ,currentTemp: String(savedData.currentTemperature)+"°C")
            cell.layer.cornerRadius = 16
            return cell
        } else {
        let plusCell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCityCell", for: indexPath) as! AddCityViewCell
            plusCell.plus.backgroundColor?.withAlphaComponent(0.6)
            plusCell.plusView.backgroundColor?.withAlphaComponent(0.7)
            plusCell.layer.cornerRadius = 16
            plusCell.plus.layer.cornerRadius = 12
            plusCell.plus.layer.masksToBounds = true
        return plusCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 {
        SelectedCityID.shared.saveSelectedCityID(selectedCityID: indexPath.row-1)
        addCity(cityName: cityCollection[indexCurrentCity].cityName)
        } else {
            performSegue(withIdentifier: "showAddCityVC", sender: cityCellsCollection)
        }
    }
    
}


extension MainViewController {
    func addCity(cityName: String) {
        tumbler = cityCollection.count
        let city = CityData(currentCityName: cityName, delegate: self)
        cityData = city
    }
}


extension MainViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(          title: title
                                             ,message: message
                                      ,preferredStyle: .alert )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
