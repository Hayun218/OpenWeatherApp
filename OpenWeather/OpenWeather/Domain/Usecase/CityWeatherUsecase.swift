//
//  CityWeatherUseCaseTemp.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation

public protocol CityWeatherUsecaseProtocol {
  func fetchCityWeather(coord: Coordinate) async -> Result<WeatherResponse, NetworkError>
}

public struct CityWeatherUsecase: CityWeatherUsecaseProtocol {
  
  private let repository: CityWeatherRepositoryProtocol
  public init(repository: CityWeatherRepositoryProtocol) {
    self.repository = repository
  }
  public func fetchCityWeather(coord: Coordinate) async -> Result<WeatherResponse, NetworkError> {
    await repository.fetchCityWeather(coord: coord)
  }
  
  
  
  
}

//class CityWeatherUseCase {
//  func transformToCityWeather(from response: WeatherResponse, cityName: String) -> CityWeather {
//    // 예시: 변환 로직 구현, Kelvin에서 Celsius로 온도 변환 및 요약 정보 생성
//    // 최근 데이터 추출
//    let latestData = response.list.first!
//    let currentTemp = latestData.main.temp - 273.15 // Kelvin to Celsius 변환
//    let minTemp = latestData.main.tempMin - 273.15
//    let maxTemp = latestData.main.tempMax - 273.15
//    let weather = latestData.weather.first?.main ?? "Unknown"
//
//    // 시간별 예보 생성
//    let hourlyForecast = response.list.map { data in
//      HourlyForecast(dateTime: Date(timeIntervalSince1970: TimeInterval(data.dt)),
//                     temp: data.main.temp - 273.15)
//    }
//
//    // 일별 예보 생성 예시 (여기서는 단순히 5일치 평균을 계산하는 방식)
//    let dailyForecast = (0..<5).map { _ in
//      DailyForecast(date: Date(), weather: weather, minTemp: minTemp, maxTemp: maxTemp)
//    }
//
//    // 평균 습도, 구름, 바람 속도 계산
//    let averageHumidity = response.list.map { $0.main.humidity }.reduce(0, +) / response.list.count
//    let averageClouds = response.list.map { $0.clouds.all }.reduce(0, +) / response.list.count
//    let averageWindSpeed = response.list.map { $0.wind.speed }.reduce(0, +) / Double(response.list.count)
//
//    return CityWeather(cityName: cityName,
//                       currentTemp: currentTemp,
//                       weather: weather,
//                       minTemp: minTemp,
//                       maxTemp: maxTemp,
//                       hourlyForecast: hourlyForecast,
//                       dailyForecast: dailyForecast,
//                       averageHumidity: Double(averageHumidity),
//                       averageClouds: averageClouds,
//                       averageWindSpeed: averageWindSpeed)
//  }
//}
