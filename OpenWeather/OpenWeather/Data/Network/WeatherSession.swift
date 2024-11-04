//
//  WeatherSessio.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Alamofire
import Foundation

// 클린 아키텍쳐: 테스트에서 mock session 주입을 위해 프로토콜 도입
public protocol SessionProtocol {
  func request(_ convertible: any URLConvertible,
               method: HTTPMethod ,
               parameters: Parameters?) -> DataRequest
}

class WeatherSession: SessionProtocol  {
  private var session: Session
  init(session: Session) {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .returnCacheDataElseLoad
    self.session = Session(configuration: config)
  }
  
  func request(_ convertible: any URLConvertible,
               method: HTTPMethod = .get,
               parameters: Parameters? = nil) -> DataRequest {
    return session.request(convertible, method: method, parameters: parameters)
  }
}
