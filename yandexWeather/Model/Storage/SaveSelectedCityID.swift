//
//  SaveSelectedCityID.swift
//  yandexWeather
//
//  Created by Георгий iMac on 25.01.2021.
//

import Foundation


class SelectedCityID {
    static let shared = SelectedCityID()
    
    private var selectedCityID = 0
    private let defaults = UserDefaults.standard
    
    func saveSelectedCityID(selectedCityID: Int) {
        defaults.set(selectedCityID, forKey: "cityID")
    } 
    
    func getSelectedCityID() -> Int {
        guard let selectedCityID = defaults.object(forKey: "cityID") else {return 0}
            self.selectedCityID = (selectedCityID as! Int)
            return self.selectedCityID
    }
}
