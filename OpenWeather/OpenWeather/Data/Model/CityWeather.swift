//
//  CityWeather.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation

struct CityWeather {
  let cityName: String
  let currentTemp: Double // 섭씨 변환된 현재 기온
  let weather: String
  let minTemp: Double // 섭씨 변환된 최저 온도
  let maxTemp: Double // 섭씨 변환된 최고 온도
  let hourlyForecast: [HourlyForecast]
  let dailyForecast: [DailyForecast]
  let averageHumidity: Double
  let averageClouds: Int
  let averageWindSpeed: Double
}

struct HourlyForecast {
  let dateTime: Date
  let temp: Double // 섭씨 변환된 기온
}

struct DailyForecast {
  let date: Date
  let weather: String
  let minTemp: Double // 섭씨 변환된 최저 온도
  let maxTemp: Double // 섭씨 변환된 최고 온도
}
