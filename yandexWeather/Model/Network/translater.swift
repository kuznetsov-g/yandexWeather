//
//  translater.swift
//  yandexWeather
//
//  Created by Георгий iMac on 07.01.2021.
//

import Foundation
import Alamofire
import SVGKit

func translateToRussian (part: String) -> (String) {
  switch part {
    case  "clear"                  : return "Ясно"
    case  "cloudy"                 : return "Облачно с прояснениями"
    case  "partly-cloudy"          : return "Малооблачно"
    case  "overcast"               : return "Пасмурно"
    case  "drizzle"                : return "Морось"
    case  "light-rain"             : return "Небольшой дождь"
    case  "rain"                   : return "Дождь"
    case  "moderate-rain"          : return "Умеренно сильный дождь"
    case  "heavy-rain"             : return "Сильный дождь"
    case  "continuous-heavy-rain"  : return "Длительный сильный дождь"
    case  "showers"                : return "Ливень"
    case  "wet-snow"               : return "Дождь со снегом"
    case  "light-snow"             : return "Небольшой снег"
    case  "snow"                   : return "Снег"
    case  "snow-showers"           : return "Снегопад"
    case  "hail"                   : return "Град"
    case  "thunderstorm"           : return "Гроза"
    case  "thunderstorm-with-rain" : return "Дождь с грозой"
    case  "thunderstorm-with-hail" : return "Гроза с градом"
        
    default:
        return "очень странное что-то"
  }
}

func weekDaysEnum (weekDayNum : Int) -> (String) {
    switch weekDayNum {
        case 1: return "Воскресенье"
        case 2: return "Понедельник"
        case 3: return "Вторник"
        case 4: return "Среда"
        case 5: return "Четверг"
        case 6: return "Пятница"
        case 7: return "Суббота"
            
        default: return "пiтница"
    }
}

