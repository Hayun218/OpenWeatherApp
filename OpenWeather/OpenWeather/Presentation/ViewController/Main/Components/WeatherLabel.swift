//
//  WeatherLabel.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation
import UIKit

final class WeatherLabel: UILabel {
  init(size: CGFloat, weight: UIFont.Weight = .regular) {
    super.init(frame: .zero)
    textColor = .white
    font = .systemFont(ofSize: size, weight: weight)
    textAlignment = .center
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
