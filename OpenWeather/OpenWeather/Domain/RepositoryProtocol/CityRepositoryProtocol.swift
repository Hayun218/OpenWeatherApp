//
//  CityRepositoryProtocol.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation


public protocol CityRepositoryProtocol {
    func getCities() -> [City]  // 모든 도시 목록
    func searchCities(by name: String) -> [City]  // 이름으로 도시 검색
    func saveCities(_ cities: [City]) throws
}
