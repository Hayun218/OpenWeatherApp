//
//  MetricItemView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

// MARK: - Main/Components/SubComponents/MetricItemView.swift
import UIKit
import SnapKit

final class MetricItemView: UIView {
    // MARK: - UI Components
    private let titleLabel = WeatherLabel(size: 14)
    private let valueLabel = WeatherLabel(size: 20, weight: .medium)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
