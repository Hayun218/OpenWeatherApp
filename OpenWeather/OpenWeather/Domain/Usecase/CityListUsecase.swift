//
//  LoadCityList.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Foundation

public protocol CityListUseCaseProtocol {
  func initialize() async -> Result<Void, ParsingError>
  func getCities() -> [City]
  func searchCities(name: String) -> [City]
}

public class CityListUseCase: CityListUseCaseProtocol {
  private let repository: CityRepositoryProtocol
  
  public init(repository: CityRepositoryProtocol) {
    self.repository = repository
  }
  
  public func initialize() async -> Result<Void, ParsingError> {
    guard let path = Bundle.main.path(forResource: "reduced_citylist", ofType: "json") else {
      return .failure(.fileNotFound)
    }
    
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      let cities = try JSONDecoder().decode([City].self, from: data)
      try repository.saveCities(cities)
      return .success(())
    } catch {
      return .failure(.decodingError)
    }
  }
  
  public func getCities() -> [City] {
    return repository.getCities()
  }
  
  public func searchCities(name: String) -> [City] {
    return repository.searchCities(by: name)
  }
}
