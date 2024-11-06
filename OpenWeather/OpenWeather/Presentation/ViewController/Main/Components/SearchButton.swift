//
//  SearchButto.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import UIKit

final class SearchButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    backgroundColor = .white.withAlphaComponent(0.3)
    layer.cornerRadius = 10
    
    let searchImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    searchImageView.tintColor = .gray
    addSubview(searchImageView)
    
    let searchLabel = UILabel()
    searchLabel.text = "Search"
    searchLabel.textColor = .gray
    addSubview(searchLabel)
    
    searchImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(20)
    }
    
    searchLabel.snp.makeConstraints { make in
      make.leading.equalTo(searchImageView.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
    }
  }
}
