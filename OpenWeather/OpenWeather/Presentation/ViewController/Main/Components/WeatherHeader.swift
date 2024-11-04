//
//  WeatherHeader.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation
import UIKit
import SnapKit

final class WeatherHeaderView: UIView {
    private let cityNameLabel = WeatherLabel(size: 36, weight: .medium)
    private let temperatureLabel = WeatherLabel(size: 60, weight: .medium)
    private let weatherLabel = WeatherLabel(size: 24)
    private let minMaxLabel = WeatherLabel(size: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [
            cityNameLabel, temperatureLabel, weatherLabel, minMaxLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with weather: CityWeather) {
        cityNameLabel.text = weather.cityName
        temperatureLabel.text = "\(Int(round(weather.currentTemp)))°"
        weatherLabel.text = weather.weather
        minMaxLabel.text = "최고: \(Int(round(weather.maxTemp)))° | 최저: \(Int(round(weather.minTemp)))°"
    }
}
