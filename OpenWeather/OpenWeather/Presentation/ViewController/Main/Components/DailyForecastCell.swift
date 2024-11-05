//
//  DailyForecastCell.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/5/24.
//

import UIKit
import SnapKit

final class DailyForecastCell: UITableViewCell {
  private let dayLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private let weatherImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()
  
  private let minMaxLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .systemFont(ofSize: 16)
    label.textAlignment = .right
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    backgroundColor = .clear
    selectionStyle = .none
    
    [dayLabel, weatherImageView, minMaxLabel].forEach {
      contentView.addSubview($0)
    }
    
    dayLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
    }
    
    weatherImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(30)
    }
    
    minMaxLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-16)
      make.centerY.equalToSuperview()
    }
  }
  
  func configure(with forecast: DailyForecast) {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"  // 요일
    formatter.locale = Locale(identifier: "ko_KR")
    
    // 오늘 날짜인지 확인
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let forecastDate = calendar.startOfDay(for: forecast.date)
    
    if calendar.isDate(today, inSameDayAs: forecastDate) {
      dayLabel.text = "오늘"
    } else {
      dayLabel.text = formatter.string(from: forecast.date)
    }
    
    let iconName = String(forecast.weatherIcon.dropLast()) + "d"
    
    weatherImageView.image = UIImage(named: iconName)
    minMaxLabel.text = "최저: \(Int(round(forecast.minTemp)))° 최고: \(Int(round(forecast.maxTemp)))°"
  }
}
