//
//  CityCellView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

// MARK: - Main/Components/CityTableViewCell.swift
import UIKit
import SnapKit

final class CityTableViewCell: UITableViewCell {
  // MARK: - UI Components
  private let cityNameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .systemFont(ofSize: 18, weight: .semibold)
    return label
  }()
  
  private let countryLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white.withAlphaComponent(0.8)
    label.font = .systemFont(ofSize: 14, weight: .regular)
    return label
  }()
  
  // MARK: - Initialization
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Setup
  private func setupUI() {
    backgroundColor = .clear
    selectionStyle = .none
    preservesSuperviewLayoutMargins = false
    contentView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    let stackView = UIStackView(arrangedSubviews: [cityNameLabel, countryLabel])
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    
    // Apply layoutMargins to stackView
    stackView.snp.makeConstraints { make in
      make.edges.equalTo(contentView.layoutMarginsGuide)
    }
  }
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cityNameLabel.text = nil
    countryLabel.text = nil
  }
  
  // MARK: - Configuration
  func configure(with city: City) {
    cityNameLabel.text = city.name
    countryLabel.text = city.country
  }
}
