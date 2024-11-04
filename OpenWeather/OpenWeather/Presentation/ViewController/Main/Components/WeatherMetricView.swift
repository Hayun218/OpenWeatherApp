//
//  WeatherMetricView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import UIKit
import SnapKit

final class WeatherMetricsView: UIView {
    private let humidityView = MetricItemView()
    private let cloudsView = MetricItemView()
    private let windSpeedView = MetricItemView()
    
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
        
        let stackView = UIStackView(arrangedSubviews: [humidityView, cloudsView, windSpeedView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func configure(humidity: Double, clouds: Int, windSpeed: Double) {
        humidityView.configure(title: "습도", value: "\(Int(round(humidity)))%")
        cloudsView.configure(title: "구름", value: "\(clouds)%")
        windSpeedView.configure(title: "바람", value: String(format: "%.1f m/s", windSpeed))
    }
}
