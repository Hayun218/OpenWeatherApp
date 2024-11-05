//
//  MetricItemView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import UIKit
import SnapKit

final class MetricItemView: UIView {
  // MARK: - UI Components
  private let titleLabel = WeatherLabel(size: 12)
  private let valueLabel = WeatherLabel(size: 32, weight: .semibold)  // 폰트 크기 증가
  
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
    backgroundColor = .white.withAlphaComponent(0.2)
    layer.cornerRadius = 12
    
    [titleLabel, valueLabel].forEach { addSubview($0) }
    
    // 타이틀은 왼쪽 상단에 배치
    titleLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview().offset(16)
      make.trailing.lessThanOrEqualToSuperview().offset(-16)
    }
    
    valueLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16) // Align to the left with 16-point padding
      make.centerY.equalToSuperview()            // Center vertically within the superview
      make.trailing.lessThanOrEqualToSuperview().offset(-16) // Ensure it doesn’t exceed the right edge
    }
    
  }
  
  // MARK: - Configuration
  func configure(title: String, value: String) {
    titleLabel.text = title
    valueLabel.text = value
  }
}
