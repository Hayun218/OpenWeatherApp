//
//  HourlyItemView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//
import UIKit

// MARK: - Main/Components/SubComponents/HourlyItemView.swift
final class HourlyItemView: UIView {
    private let timeLabel = WeatherLabel(size: 14)
    private let tempLabel = WeatherLabel(size: 16, weight: .medium)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [timeLabel, tempLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(time: String, temperature: String) {
        timeLabel.text = time
        tempLabel.text = temperature
    }
}

