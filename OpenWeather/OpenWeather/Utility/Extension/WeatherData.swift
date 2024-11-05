//
//  WeatherData.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/5/24.
//

import Foundation

extension WeatherData {
  func debugPrint() {
    print("""
            DEBUG: Weather Data:
            Date Text: \(dtTxt)
            Temperature: \(main.temp)
            Weather: \(weather.first?.main ?? "N/A")
            Icon: \(weather.first?.icon ?? "N/A")
            """)
  }
}
