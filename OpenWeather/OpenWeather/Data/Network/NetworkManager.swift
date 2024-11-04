//
//  NetworkManager.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Alamofire
import Foundation


public class NetworkManager {
  private let session: SessionProtocol
  
  init(session: SessionProtocol) {
    self.session = session
  }
  
  // 제네릭 활용
  func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters) async -> Result<T, NetworkError> {
    // url 유효성 검사
    guard let url = URL(string: url) else {
      return .failure(.urlError)
    }
    // request 진행
    let result = await session.request(url, method: method, parameters: parameters).serializingData().response
    
    // 에러 핸들링
    if let error = result.error {return .failure(.requestFailed(error.localizedDescription))}
    guard let data = result.data else {return .failure(.dataNil)}
    guard let response = result.response else { return .failure(.invalidResponse)}
    
    if 200..<400 ~= response.statusCode {
      do {
        let data = try JSONDecoder().decode(T.self, from: data)
        return .success(data)
      } catch {
        return .failure(.failToDecode(error.localizedDescription))
      }
    } else {
      return .failure(.serverError(response.statusCode))
    }
  }
  
}
