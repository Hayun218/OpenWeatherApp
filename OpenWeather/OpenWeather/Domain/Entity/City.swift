//
//  City.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/1/24.
//

import Foundation

public struct Coordinate: Decodable, Encodable {
  let lon: Double
  let lat: Double
}

public struct City: Decodable, Encodable {
  let id: Int
  let name: String
  let country: String
  let coord: Coordinate
}
