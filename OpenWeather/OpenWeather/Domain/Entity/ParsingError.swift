//
//  CacheError.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation

public enum ParsingError: Error {
  case fileNotFound
  case readError
  case writeError
  case invalidData
  case encodingError
  case decodingError
  
  public var description: String {
    switch self {
    case .fileNotFound:
      "Json 파일을 찾을 수 없습니다"
    case .readError:
      "캐시 읽기 실패"
    case .writeError:
      "캐시 쓰기 실패"
    case .invalidData:
      "유효하지 않은 데이터입니다"
    case .encodingError:
      "데이터 인코딩 실패"
    case .decodingError:
      "데이터 디코딩 실패"
    }
  }
}
