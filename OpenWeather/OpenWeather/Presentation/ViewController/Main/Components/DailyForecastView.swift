//
//  DailyForecastView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation
import UIKit
import SnapKit

final class DailyForecastView: UIView {
  private let stackView = UIStackView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    backgroundColor = .white.withAlphaComponent(0.2)
    layer.cornerRadius = 12
    
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 12
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }
  }
  
  func configure(with forecasts: [DailyForecast]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E"
    dateFormatter.locale = Locale(identifier: "ko_KR")
    
    forecasts.forEach { forecast in
      let dailyView = DailyItemView()
      dailyView.configure(
        day: dateFormatter.string(from: forecast.date),
        weather: forecast.weather,
        minTemp: "\(Int(round(forecast.minTemp)))°",
        maxTemp: "\(Int(round(forecast.maxTemp)))°"
      )
      stackView.addArrangedSubview(dailyView)
    }
  }
}

