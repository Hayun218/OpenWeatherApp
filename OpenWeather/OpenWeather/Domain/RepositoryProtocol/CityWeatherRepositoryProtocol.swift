//
//  CityWeatherRepository.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation

public protocol CityWeatherRepositoryProtocol {
  func fetchCityWeather(coord: Coordinate) async -> Result<WeatherResponse, NetworkError>
}
