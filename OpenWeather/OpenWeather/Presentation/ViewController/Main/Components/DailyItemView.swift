//
//  DailyItemView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation
import UIKit

// MARK: - Main/Components/SubComponents/DailyItemView.swift
final class DailyItemView: UIView {
    private let dayLabel = WeatherLabel(size: 16)
    private let weatherLabel = WeatherLabel(size: 16)
    private let tempLabel = WeatherLabel(size: 16)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [dayLabel, weatherLabel, tempLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(day: String, weather: String, minTemp: String, maxTemp: String) {
        dayLabel.text = day
        weatherLabel.text = weather
        tempLabel.text = "\(maxTemp) / \(minTemp)"
    }
}


