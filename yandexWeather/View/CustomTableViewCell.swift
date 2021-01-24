//
//  CustomTableViewCell.swift
//  yandexWeather
//
//  Created by Георгий iMac on 08.01.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherImage: CustomImageView!
    @IBOutlet weak var weekDayLable: UILabel!
    @IBOutlet weak var conditionLable: UILabel!
    @IBOutlet weak var dayTempLable: UILabel!
    @IBOutlet weak var nightTempLable: UILabel!
//    @IBOutlet weak var tableCellView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated) }
    
    func commonInit(imageURL: String,weekDay: String, condition: String, dayTemp: Int, nightTemp: Int) {
//        weatherImage.loadImageUsingUrlString(urlString: "https://yastatic.net/weather/i/icons/blueye/color/svg/bkn_n.svg")
//        weekDayLable.text   = "фторник"
//        dayTempLable.text   = String(15)
//        nightTempLable.text = String(-15)
//        conditionLable.text = "cloudy-and-rain"
        
        
        weatherImage.loadImageUsingUrlString(urlString: imageURL)
        weekDayLable.text   = weekDay
        dayTempLable.text   = String(dayTemp)
        nightTempLable.text = String(nightTemp)
        conditionLable.text = condition
    }
}
