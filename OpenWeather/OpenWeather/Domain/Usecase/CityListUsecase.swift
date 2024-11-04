//
//  LoadCityList.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation

public protocol CityListUsecaseProtocol {
  /// Loads all city data from the JSON file
  /// - store it in cache
  func loadCityList() async -> Result<[City], Error>
}
//
//public class CityListUsecase: CityListUsecaseProtocol {
//  private var cities: [City] = []
//  private let cacheFileName = "citylist_cache.json"
//  
//  /// Loads the city list, either from cache or by parsing the JSON file.
//  public func loadCityList() async -> Result<[City], Error> {
//    // 먼저 캐시에서 데이터를 로드
//    if let cachedCities = loadCityListFromCache() {
//      self.cities = cachedCities
//      return .success(cities)
//    }
//    
//    // 캐시가 없을 경우, JSON 파일에서 데이터를 로드하고 캐시에 저장
//    do {
//      if let path = Bundle.main.path(forResource: "citylist", ofType: "json") {
//        let data = try Data(contentsOf: URL(fileURLWithPath: path))
//        self.cities = try JSONDecoder().decode([City].self, from: data)
//        
//        // 로드된 데이터를 캐시에 저장
//        cacheCityList(self.cities)
//        return .success(cities)
//      } else {
//        return .failure(NSError(domain: "File not found", code: -1, userInfo: nil))
//      }
//    } catch {
//      return .failure(error)
//    }
//  }
//  
//  // MARK: - Private Cache Handling Methods
//  
//  /// Saves the city list to a cache file.
//  private func cacheCityList(_ cities: [City]) {
//    let url = FileManager.default.temporaryDirectory.appendingPathComponent(cacheFileName)
//    if let encodedData = try? JSONEncoder().encode(cities) {
//      try? encodedData.write(to: url)
//    }
//  }
//  
//  /// Loads the city list from a cache file, if available.
//  private func loadCityListFromCache() -> [City]? {
//    let url = FileManager.default.temporaryDirectory.appendingPathComponent(cacheFileName)
//    if let data = try? Data(contentsOf: url),
//       let cachedCities = try? JSONDecoder().decode([City].self, from: data) {
//      return cachedCities
//    }
//    return nil
//  }
//  
//  /// Getter for cities list
//  public func getCities() -> [City] {
//    return cities
//  }
//}
