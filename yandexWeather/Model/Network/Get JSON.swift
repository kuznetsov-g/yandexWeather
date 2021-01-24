//
//  getJSON.swift
//  yandexWeather
//
//  Created by Георгий iMac on 20.12.2020.
//

import Alamofire
import Foundation
import SVGKit
import RealmSwift

protocol CityDataDelegate: class {
    func updateTop(cityName: String, haveData: Bool)
}

class CityData {
    var weatherData = WeatherData()
    
    var cityCoordinateLat  = "0.0"
    var cityCoordinateLong = "0.0"
    var cityCordinates     = "0 0"
    var currentCityName    = "City Name"
    
    var arrayOfURLs         : [String] = []

    weak var cityDataDelegate: CityDataDelegate!
    
    init(currentCityName: String, delegate: CityDataDelegate) {
        guard let encodedCityName = currentCityName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) else {return}
        self.currentCityName = encodedCityName
        self.cityDataDelegate = delegate
        getCityData()
    }
    
    private func getCityData() -> () {
        let apiKey = "23828a58-4738-4bac-8372-18ad369a78d7"
        let geoURL = "https://geocode-maps.yandex.ru/1.x/?format=json&apikey="+apiKey+"&geocode="+currentCityName+"&results=1"
        
        AF.request(geoURL).responseData { responseJSON in
            switch responseJSON.result {
                case .success(let value):
                    do { let cityData = try JSONDecoder().decode(CityJSON.self, from: value )
                            if cityData.response.GeoObjectCollection.metaDataProperty.GeocoderResponseMetaData.found == "0" {
                            self.cityDataDelegate.updateTop(cityName: cityData.response.GeoObjectCollection.metaDataProperty.GeocoderResponseMetaData.request,
                                                            haveData: false)
                            } else {
                                self.weatherData.cityName = cityData.response.GeoObjectCollection.featureMember[0].GeoObject.name
                                self.cityCordinates = cityData.response.GeoObjectCollection.featureMember[0].GeoObject.Point.pos
                                self.getCityCoordinates()
                                }
                    } catch let error { print ("error while fetching geocoder data",error)}
                case .failure(let error):
                print("error while fetching geocoder data",error)
            }
        }
    }

    private func getCityCoordinates() -> () {
        let coordinatesArray = self.cityCordinates.components(separatedBy: " ")
        self.cityCoordinateLong = coordinatesArray[0]
        self.cityCoordinateLat  = coordinatesArray[1]
        self.getCityWeatherData()
    }
    
    private func getCityWeatherData() -> () {
        let weatherURL = "https://api.weather.yandex.ru/v2/forecast?&lat="+self.cityCoordinateLat+"&lon="+self.cityCoordinateLong+"&lang=ru_RU&limit=7&hours=true&extra=false"
        AF.request(weatherURL, method: .get, headers: ["X-Yandex-API-Key":"b6cb2e4f-6a7a-4a96-a697-12d3bd32e20d"]).responseData{
            (responseData) in
            switch responseData.result {
            case  .success(let value):
               do { let weatherData = try JSONDecoder().decode(WeatherStruct.self, from: value)
                self.weatherData.currentTemperature = weatherData.fact.temp
                self.getArrayOfImageNames(weatherData: weatherData)
                self.getForecastsData(weatherForecasts:  weatherData.forecasts)
               } catch let error {print(error)}
            case .failure(let error):
            print(error)
            }
        }
    }
    
    private func getArrayOfImageNames(weatherData: WeatherStruct) -> () {
        var arrayOfImageNames: [String] = []
        for x in 0...weatherData.forecasts.count-1 {
            arrayOfImageNames += [weatherData.forecasts[x].parts.day.icon]
        }
        arrayOfImageNames += [weatherData.fact.icon]
        self.weatherData.currentWeatherimageURL =
            "https://yastatic.net/weather/i/icons/blueye/color/svg/"+weatherData.fact.icon+".svg"
        for name in arrayOfImageNames {
            arrayOfURLs.append("https://yastatic.net/weather/i/icons/blueye/color/svg/"+name+".svg")
        }
    }
    
    private func getForecastsData (weatherForecasts: [ForecastStruct]) -> () {
        var id = -5
        for x in 0...weatherForecasts.count-1 {
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-mm-dd"
            let date = dateFormatter.date(from: weatherForecasts[x].date)!
            let numWeekDay = Calendar.current.component(.weekday, from: date)
            let weekDay = weekDaysEnum(weekDayNum: numWeekDay)
            let forecastData = ForecastData()
                forecastData.condition = translateToRussian(part: weatherForecasts[x].parts.day.condition)
                forecastData.dayTemperature = weatherForecasts[x].parts.day.temp_avg
                forecastData.nightTemperature = weatherForecasts[x].parts.night.temp_avg
                forecastData.weatherImageURL = self.arrayOfURLs[x]
                forecastData.weekDay = weekDay
            self.weatherData.forecasts.append(forecastData)
        }
            if realm.objects(WeatherData.self).count > 0 {
                for x in 0...realm.objects(WeatherData.self).count-1 {
                    if realm.objects(WeatherData.self)[x].cityName == self.weatherData.cityName {
                        id = realm.objects(WeatherData.self)[x].id
                    }
                }
            } else { id = 0 }
        if id == -5 { id = realm.objects(WeatherData.self).count}
        weatherData.id = id
        StorageManager.saveWeatherData(weatherData: weatherData)
        self.sendDataToView()
    }
    
   private func sendDataToView () -> () {
    self.cityDataDelegate.updateTop(cityName: self.weatherData.cityName , haveData: true)
   }
}

