//
//  JSON City Structure.swift
//  yandexWeather
//
//  Created by Георгий iMac on 21.12.2020.
//

import Foundation
import UIKit

// Структура данных JSON с Яндекса для запроса координат по названию населенного пункта.
// Нужно для добавления координат в ссылку для запроса погоды
struct CityJSON: Decodable {
    var response : ResponseStruct
}

struct ResponseStruct: Decodable {
    var GeoObjectCollection : GeoObjectCollectionStruct
}

struct GeoObjectCollectionStruct: Decodable {
    var featureMember : [FeatureMemberStruct]
    var metaDataProperty : MetaDataPropertyStruct
}

struct MetaDataPropertyStruct: Decodable {
    var GeocoderResponseMetaData: GeocoderResponseMetaDataStruct
}

struct GeocoderResponseMetaDataStruct: Decodable {
    var request: String
    var found  : String
}

struct FeatureMemberStruct: Decodable {
    var GeoObject : GeoObjectStruct
}

struct GeoObjectStruct: Decodable {
    var name  : String                       // имя города
    var Point : PointStruct
}

struct PointStruct: Decodable {
    var pos : String                        //координаты в формате 56.229434 58.01045 (долгота / широта)
}
