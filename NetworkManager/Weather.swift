//
//  Weather.swift
//  NetworkManager
//
//  Created by Utsav Hitendrabhai Pandya on 15/01/26.
//


import Foundation

struct Weather: Codable {
    let city: String
    let country: String
    let temperatureC: Int
    let condition: String
    let humidity: Int
    let windKph: Int
    let lastUpdated: Date

    enum CodingKeys: String, CodingKey {
        case city
        case country
        case temperatureC = "temperature_c"
        case condition
        case humidity
        case windKph = "wind_kph"
        case lastUpdated = "last_updated"
    }
}
