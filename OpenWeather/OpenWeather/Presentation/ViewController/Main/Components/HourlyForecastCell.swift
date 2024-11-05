//
//  HourlyForecastCell.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/5/24.
//

import UIKit
import SnapKit


final class HourlyForecastCell: UICollectionViewCell {
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .systemFont(ofSize: 14)
    label.textAlignment = .center
    return label
  }()
  
  private let weatherImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()
  
  private let temperatureLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .systemFont(ofSize: 16)
    label.textAlignment = .center
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    [timeLabel, weatherImageView, temperatureLabel].forEach {
      contentView.addSubview($0)
    }
    
    timeLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    
    weatherImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(30)
    }
    
    temperatureLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
  
  func configure(with forecast: HourlyForecast) {
    timeLabel.text = forecast.formattedTime
    temperatureLabel.text = "\(Int(round(forecast.temp)))°"
    let iconName = String(forecast.weatherIcon.dropLast()) + "d"
    weatherImageView.image = UIImage(named: iconName)
  }
}
