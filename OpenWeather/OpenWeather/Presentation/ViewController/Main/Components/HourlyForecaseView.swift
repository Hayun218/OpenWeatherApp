//
//  HourlyForecaseView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import Foundation
import UIKit
import SnapKit

final class HourlyForecastView: UIView {
    private let scrollView = UIScrollView()
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
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.showsHorizontalScrollIndicator = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    func configure(with forecasts: [HourlyForecast]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        forecasts.forEach { forecast in
            let hourView = HourlyItemView()
            hourView.configure(
                time: dateFormatter.string(from: forecast.dateTime),
                temperature: "\(Int(round(forecast.temp)))°"
            )
            stackView.addArrangedSubview(hourView)
        }
    }
}
