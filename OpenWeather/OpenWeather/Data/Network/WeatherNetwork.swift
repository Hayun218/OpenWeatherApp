//
//  WeatherNetwork.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation

final public class WeatherNetwork {
  private let manager: NetworkManagerProtocol
  init(manager: NetworkManagerProtocol) {
    self.manager = manager
  }
  
  func fetchCityWeather(coord: Coordinate) async -> Result<WeatherResponse, NetworkError> {
    let url = "api.openweathermap.org/data/2.5/forecast?lat=\(coord.lat)&lon=\(coord.lon)&APPID=c2ddfcfa1f450dbf30cbd8b8550c56e7"
    
    return await manager.fetchData(url: url, method: .get, parameters: nil)
  }
}
