//
//  NetworkManager.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/4/24.
//

import Alamofire
import Foundation


public protocol NetworkManagerProtocol {
  func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters?) async -> Result<T, NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    func fetchData<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?
    ) async -> Result<T, NetworkError> {
      let urlString = "http://\(url)"
        guard let url = URL(string: urlString) else {
            return .failure(.urlError)
        }
        
        let result = await AF.request(url, method: method, parameters: parameters)
            .serializingData()
            .response
        
        if let error = result.error {
            return .failure(.requestFailed(error.localizedDescription))
        }
        
        guard let data = result.data else {
            return .failure(.dataNil)
        }
        
        guard let response = result.response else {
            return .failure(.invalidResponse)
        }
        
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
