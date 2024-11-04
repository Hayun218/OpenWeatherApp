//
//  CityRepository.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation

public class CityRepository: CityRepositoryProtocol {
  private let defaults = UserDefaults.standard
  private let storageKey = "cached_cities"
  private var citiesCache: [City]?
  
  public init() {}
  
  public func getCities() -> [City] {
    if let cachedCities = citiesCache {
      return cachedCities
    }
    
    guard let data = defaults.data(forKey: storageKey),
          let cities = try? JSONDecoder().decode([City].self, from: data) else {
      return []
    }
    citiesCache = cities
    return cities
  }
  
  public func searchCities(by name: String) -> [City] {
    let cities = getCities()
    guard !name.isEmpty else { return cities }
    
    let searchTerm = name.lowercased()
    return cities.filter { $0.name.lowercased().contains(searchTerm) }
  }
  
  public func saveCities(_ cities: [City]) throws {
    let encodedData = try JSONEncoder().encode(cities)
    defaults.set(encodedData, forKey: storageKey)
    citiesCache = cities
  }
}
