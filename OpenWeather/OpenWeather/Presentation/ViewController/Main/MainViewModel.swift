// MARK: - Presentation/ViewModel/MainViewModel.swift
import Foundation
import RxSwift
import RxRelay

final class MainViewModel {
  
  // MARK: - Properties
  private let weatherUseCase: CityWeatherUsecaseProtocol
  private let cityListUseCase: CityListUseCaseProtocol // 추가
  
  init(weatherUseCase: CityWeatherUsecaseProtocol, cityListUseCase: CityListUseCaseProtocol) {
    self.weatherUseCase = weatherUseCase
    self.cityListUseCase = cityListUseCase
    fetchInitialWeather()
  }
  
  // cityListUseCase getter 추가
  func getCityListUseCase() -> CityListUseCaseProtocol {
    return cityListUseCase
  }
  private let disposeBag = DisposeBag()
  
  // MARK: - Observable properties
  private let weatherStateRelay = BehaviorRelay<LoadingState<CityWeather>>(value: .idle)
  private let errorMessageRelay = PublishRelay<String>()
  
  var weatherState: Observable<LoadingState<CityWeather>> {
    return weatherStateRelay.asObservable()
  }
  
  var errorMessage: Observable<String> {
    return errorMessageRelay.asObservable()
  }
  
  // MARK: - Public methods
  private func fetchInitialWeather() {
    let initialCity = City(
      id: 1839726,
      name: "Asan",
      country: "KR",
      coord: Coordinate(lon: 127.004173, lat: 36.783611)
    )
    fetchWeatherData(for: initialCity)
  }
  
  func fetchWeatherData(for city: City) {
    weatherStateRelay.accept(.loading)
    
    Task {
      let result = await weatherUseCase.fetchCityWeather(coord: city.coord)
      
      await MainActor.run {
        switch result {
        case .success(let response):
          let cityWeather = self.processCityWeather(response, for: city)
          self.weatherStateRelay.accept(.loaded(cityWeather))
        case .failure(let error):
          self.weatherStateRelay.accept(.error)
          self.errorMessageRelay.accept(error.localizedDescription)
        }
      }
    }
  }
  
  // MARK: - Private methods
  private func processCityWeather(_ response: WeatherResponse, for city: City) -> CityWeather {
    let currentData = response.list.first!
    
    return CityWeather(
      cityName: city.name,
      currentTemp: kelvinToCelsius(currentData.main.temp),
      weather: currentData.weather.first?.main ?? "",
      minTemp: kelvinToCelsius(currentData.main.tempMin),
      maxTemp: kelvinToCelsius(currentData.main.tempMax),
      hourlyForecast: processHourlyForecast(response.list),
      dailyForecast: processDailyForecast(response.list),
      averageHumidity: calculateAverageHumidity(response.list),
      averageClouds: calculateAverageClouds(response.list),
      averageWindSpeed: calculateAverageWindSpeed(response.list)
    )
  }
  
  private func processHourlyForecast(_ list: [WeatherData]) -> [HourlyForecast] {
    return list.prefix(24).compactMap { data in
      guard let date = ISO8601DateFormatter.weatherDateFormatter.date(from: data.dtTxt) else {
        return nil
      }
      return HourlyForecast(
        dateTime: date,
        temp: kelvinToCelsius(data.main.temp)
      )
    }
  }
  
  private func processDailyForecast(_ list: [WeatherData]) -> [DailyForecast] {
    let calendar = Calendar.current
    var dailyData: [Date: [WeatherData]] = [:]
    
    list.forEach { data in
      guard let date = ISO8601DateFormatter.weatherDateFormatter.date(from: data.dtTxt) else { return }
      let startOfDay = calendar.startOfDay(for: date)
      dailyData[startOfDay, default: []].append(data)
    }
    
    return dailyData.map { date, dayData in
      DailyForecast(
        date: date,
        weather: findMostCommonWeather(in: dayData),
        minTemp: kelvinToCelsius(dayData.map { $0.main.tempMin }.min() ?? 0),
        maxTemp: kelvinToCelsius(dayData.map { $0.main.tempMax }.max() ?? 0)
      )
    }
    .sorted { $0.date < $1.date }
  }
  
  private func findMostCommonWeather(in data: [WeatherData]) -> String {
    let weatherCounts = data.reduce(into: [String: Int]()) { counts, weatherData in
      if let weather = weatherData.weather.first?.main {
        counts[weather, default: 0] += 1
      }
    }
    return weatherCounts.max(by: { $0.value < $1.value })?.key ?? ""
  }
  
  private func calculateAverageHumidity(_ list: [WeatherData]) -> Double {
    Double(list.map { $0.main.humidity }.reduce(0, +)) / Double(list.count)
  }
  
  private func calculateAverageClouds(_ list: [WeatherData]) -> Int {
    Int(round(Double(list.map { $0.clouds.all }.reduce(0, +)) / Double(list.count)))
  }
  
  private func calculateAverageWindSpeed(_ list: [WeatherData]) -> Double {
    let average = list.map { $0.wind.speed }.reduce(0, +) / Double(list.count)
    return round(average * 10) / 10
  }
  
  private func kelvinToCelsius(_ kelvin: Double) -> Double {
    return round((kelvin - 273.15) * 10) / 10
  }
}

// MARK: - LoadingState enum
enum LoadingState<T> {
  case idle
  case loading
  case loaded(T)
  case error
}

// MARK: - DateFormatter Extension
extension ISO8601DateFormatter {
  static let weatherDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
}
