//
//  CityWeather.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation
struct CityWeather {
  let cityName: String
  let todayForecast: TodayForecast
  let hourlyForecast: [HourlyForecast]
  let dailyForecast: [DailyForecast]
}

struct TodayForecast {
  let currentTemp: Double // 현재 날씨
  let weather: String // 오늘의 전반적인 날씨
  let weatherIcon: String // 오늘의 전반적인 날씨에 대한 아이콘
  let minTemp: Double // 오늘 최저
  let maxTemp: Double // 오늘 최대
  let averageHumidity: Double // 오늘 평균 습도
  let averageClouds: Int
  let averageWindSpeed: Double
}

struct HourlyForecast {
  let dateTime: Date
  let temp: Double
  let weatherIcon: String  // 아이콘 추가
  let weather: String      // 날씨 상태 추가
  let formattedTime: String
}

struct DailyForecast {
  let date: Date
  let weather: String
  let weatherIcon: String  // 아이콘 추가
  let minTemp: Double
  let maxTemp: Double
}


// CityWeather.swift에 empty 함수 추가
extension CityWeather {
  static func empty(for city: City) -> CityWeather {
    return CityWeather(
      cityName: city.name,
      todayForecast: TodayForecast(
        currentTemp: 0,
        weather: "",
        weatherIcon: "",
        minTemp: 0,
        maxTemp: 0,
        averageHumidity: 0,
        averageClouds: 0,
        averageWindSpeed: 0
      ),
      hourlyForecast: [],
      dailyForecast: []
    )
  }
}
