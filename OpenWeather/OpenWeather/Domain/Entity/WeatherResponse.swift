//
//  Weather.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/1/24.
//

import Foundation


public struct WeatherResponse: Decodable {
  let cod: String
  let message: Int
  let cnt: Int
  let list: [WeatherData]
}

struct WeatherData: Decodable {
  let dt: Int // Unix timestamp
  let main: MainWeather
  let weather: [WeatherCondition]
  let clouds: Clouds
  let wind: Wind
  let dtTxt: String
  
  enum CodingKeys: String, CodingKey {
    case dt, main, weather, clouds, wind
    case dtTxt = "dt_txt"
  }
}

struct MainWeather: Decodable {
  let temp: Double
  let tempMin: Double
  let tempMax: Double
  let humidity: Int
  
  enum CodingKeys: String, CodingKey {
    case temp
    case tempMin = "temp_min"
    case tempMax = "temp_max"
    case humidity
  }
}

struct WeatherCondition: Decodable {
  let id: Int
  let icon: String
  let main: String
  let description: String
  
}

struct Clouds: Decodable {
  let all: Int
}

struct Wind: Decodable {
  let speed: Double
}
