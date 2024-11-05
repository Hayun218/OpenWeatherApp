// MARK: - Presentation/ViewModel/MainViewModel.swift
import Foundation
import RxSwift
import RxCocoa

protocol MainViewModelProtocol {
  func transform(input: MainViewModel.Input) -> MainViewModel.Output
}

// MARK: - MainViewModel
final class MainViewModel {
  private let weatherUseCase: CityWeatherUsecaseProtocol
  private let citySearchViewModel: CitySearchViewModel  // 참조 유지
  private let disposeBag = DisposeBag()
  
  private let weatherStateRelay = BehaviorRelay<LoadingState<CityWeather>>(value: .idle)
  private let errorMessageRelay = PublishRelay<String>()
  
  init(weatherUseCase: CityWeatherUsecaseProtocol, citySearchViewModel: CitySearchViewModel) {
    self.weatherUseCase = weatherUseCase
    self.citySearchViewModel = citySearchViewModel
    
    // 초기 날씨 데이터 로드
    fetchWeatherData(for: citySearchViewModel.currentSelectedCity)
    
    // 도시 선택 변경 구독
    citySearchViewModel.transform(
      input: .init(
        viewWillAppear: .empty(),
        searchText: .empty(),
        citySelected: .empty()
      )
    )
    .selectedCity
    .distinctUntilChanged { $0.id == $1.id }
    .bind(onNext: { [weak self] city in
      self?.fetchWeatherData(for: city)
    })
    .disposed(by: disposeBag)
  }
  
  public struct Input {
    let viewWillAppear: Observable<Void>
    let refreshTrigger: Observable<Void>
  }
  
  public struct Output {
    let weatherState: Observable<LoadingState<CityWeather>>
    let errorMessage: Observable<String>
    let coordinates: Observable<Coordinate>
  }
  
  public func transform(input: Input) -> Output {
    // 화면 새로고침
    Observable.merge(
      input.viewWillAppear,
      input.refreshTrigger
    )
    .map { [weak self] _ -> City in
      guard let self = self else {
        return self?.citySearchViewModel.currentSelectedCity ?? City.default
      }
      return self.citySearchViewModel.currentSelectedCity
    }
    .bind(onNext: { [weak self] city in
      self?.fetchWeatherData(for: city)
    })
    .disposed(by: disposeBag)
    
    let coordinates = weatherStateRelay
      .compactMap { state -> Coordinate? in
        if case .loaded(let weather) = state {
          return self.citySearchViewModel.currentSelectedCity.coord
        }
        return nil
      }
    
    return Output(
      weatherState: weatherStateRelay.asObservable(),
      errorMessage: errorMessageRelay.asObservable(),
      coordinates: coordinates.asObservable()
    )
  }
  
  private func fetchWeatherData(for city: City) {
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
  
  private func calculateAverageClouds(_ list: [WeatherData]) -> Int {
    guard !list.isEmpty else { return 0 }  // 빈 배열일 경우 0 반환
    
    let sum = list.map { $0.clouds.all }.reduce(0, +)
    return Int(round(Double(sum) / Double(list.count)))
  }
  
  private func calculateAverageHumidity(_ list: [WeatherData]) -> Double {
    guard !list.isEmpty else { return 0 }  // 빈 배열일 경우 0 반환
    
    let sum = list.map { $0.main.humidity }.reduce(0, +)
    return Double(sum) / Double(list.count)
  }
  
  private func calculateAverageWindSpeed(_ list: [WeatherData]) -> Double {
    guard !list.isEmpty else { return 0 }  // 빈 배열일 경우 0 반환
    
    let sum = list.map { $0.wind.speed }.reduce(0, +)
    return round(sum / Double(list.count) * 10) / 10
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


// MARK: - MainViewModel Processing Functions
extension MainViewModel {
  private func getTodayForecasts(_ list: [WeatherData]) -> [WeatherData] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let calendar = Calendar.current
    
    // 날짜별로 데이터 그룹화
    var dailyData: [Date: [WeatherData]] = [:]
    
    list.forEach { data in
      guard let date = dateFormatter.date(from: data.dtTxt) else {
        print("DEBUG: Failed to parse date: \(data.dtTxt)")
        return
      }
      
      let startOfDay = calendar.startOfDay(for: date)
      dailyData[startOfDay, default: []].append(data)
    }
    
    // 오늘 날짜 가져오기
    let today = calendar.startOfDay(for: Date())
    
    // 오늘 날짜의 데이터만 반환
    return dailyData[today] ?? []
  }
  
  // processCityWeather 함수 수정
  private func processCityWeather(_ response: WeatherResponse, for city: City) -> CityWeather {
    guard !response.list.isEmpty else {
      return CityWeather.empty(for: city)
    }
    
    // 오늘의 데이터만 필터링
    let todayForecasts = getTodayForecasts(response.list)
    print("DEBUG: Today forecasts count - \(todayForecasts.count)")
    
    let dailyForecasts = processDailyForecast(response.list)
    guard let todayDailyForecast = dailyForecasts.first else {
      return CityWeather.empty(for: city)
    }
    
    let hourlyForecasts = processHourlyForecast(response.list)
    guard let currentHourlyForecast = hourlyForecasts.first else {
      return CityWeather.empty(for: city)
    }
    
    let todayForecast = TodayForecast(
      currentTemp: currentHourlyForecast.temp,
      weather: todayDailyForecast.weather,
      weatherIcon: todayDailyForecast.weatherIcon,
      minTemp: todayDailyForecast.minTemp,
      maxTemp: todayDailyForecast.maxTemp,
      averageHumidity: calculateAverageHumidity(todayForecasts),
      averageClouds: calculateAverageClouds(todayForecasts),
      averageWindSpeed: calculateAverageWindSpeed(todayForecasts)
    )
    
    return CityWeather(
      cityName: city.name,
      todayForecast: todayForecast,
      hourlyForecast: hourlyForecasts,
      dailyForecast: dailyForecasts
    )
  }
  
  private func processHourlyForecast(_ list: [WeatherData]) -> [HourlyForecast] {
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.locale = Locale(identifier: "ko_KR")
    outputDateFormatter.dateFormat = "a h시"  // "오전 11시" 또는 "오후 1시" 형식
    
    // 현재 시간부터 48시간 후까지
    let currentDate = Date()
    guard let endDate = Calendar.current.date(byAdding: .hour, value: 49, to: currentDate) else {
      return []
    }
    
    // 데이터 필터링
    let filteredList = list.filter { data in
      guard let date = inputDateFormatter.date(from: data.dtTxt) else {
        return false
      }
      return date >= currentDate && date <= endDate
    }
    
    return filteredList.enumerated().map { index, data in
      let date = inputDateFormatter.date(from: data.dtTxt) ?? Date()
      let formattedTime = index == 0 ? "지금" : outputDateFormatter.string(from: date)
      
      return HourlyForecast(
        dateTime: date,
        temp: kelvinToCelsius(data.main.temp),
        weatherIcon: data.weather.first?.icon ?? "",
        weather: data.weather.first?.main ?? "",
        formattedTime: formattedTime
      )
    }
  }
  
  private func processDailyForecast(_ list: [WeatherData]) -> [DailyForecast] {
    print("DEBUG: Processing daily forecasts. List count: \(list.count)")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let calendar = Calendar.current
    var dailyData: [Date: [WeatherData]] = [:]
    
    // 날짜별로 데이터 그룹화
    list.forEach { data in
      guard let date = dateFormatter.date(from: data.dtTxt) else {
        print("DEBUG: Failed to parse date: \(data.dtTxt)")
        return
      }
      
      let startOfDay = calendar.startOfDay(for: date)
      dailyData[startOfDay, default: []].append(data)
      print("DEBUG: Added data for date: \(startOfDay)")
    }
    
    // 각 날짜별 예보 생성
    let forecasts = dailyData.map { date, dayData in
      let mostCommonWeather = findMostCommonWeather(in: dayData)
      let mostCommonIcon = findMostCommonIcon(in: dayData)
      
      return DailyForecast(
        date: date,
        weather: mostCommonWeather,
        weatherIcon: mostCommonIcon,
        minTemp: kelvinToCelsius(dayData.map { $0.main.tempMin }.min() ?? 0),
        maxTemp: kelvinToCelsius(dayData.map { $0.main.tempMax }.max() ?? 0)
      )
    }
      .sorted { $0.date < $1.date }
      .prefix(5)
      .map { $0 }
    
    print("DEBUG: Generated \(forecasts.count) daily forecasts")
    return Array(forecasts)
  }
}

private func findMostCommonWeather(in data: [WeatherData]) -> String {
  let weatherCounts = data.reduce(into: [String: Int]()) { counts, weatherData in
    if let weather = weatherData.weather.first?.main {
      counts[weather, default: 0] += 1
    }
  }
  return weatherCounts.max(by: { $0.value < $1.value })?.key ?? ""
}

private func findMostCommonIcon(in data: [WeatherData]) -> String {
  let iconCounts = data.reduce(into: [String: Int]()) { counts, weatherData in
    if let icon = weatherData.weather.first?.icon {
      counts[icon, default: 0] += 1
    }
  }
  return iconCounts.max(by: { $0.value < $1.value })?.key ?? ""
}

