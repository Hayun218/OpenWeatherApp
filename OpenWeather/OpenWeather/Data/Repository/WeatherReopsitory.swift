//
//  WeatherReopsitory.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation

final class WeatherRepository: CityWeatherRepositoryProtocol {
  private let network: WeatherNetworkProtocol
  
  init(network: WeatherNetworkProtocol) {
    self.network = network
  }
  
  func fetchCityWeather(coord: Coordinate) async -> Result<WeatherResponse, NetworkError> {
    await network.fetchCityWeather(coord: coord)
  }
}
