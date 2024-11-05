//
//  HourlyForecaseView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

//
//  HourlyForecaseView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import UIKit
import SnapKit

final class HourlyForecastView: UIView {
  private let hourlyCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 30  // 간격 넓게
    layout.itemSize = CGSize(width: 70, height: 90)  // 셀 크기 줄임
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white.withAlphaComponent(0.2)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: "HourlyCell")
    collectionView.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)  // 좌우 여백 추가
    collectionView.layer.cornerRadius = 15
    collectionView.clipsToBounds = true     
    return collectionView
  }()
  
  private var forecasts: [HourlyForecast] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    
    addSubview(hourlyCollectionView)
    hourlyCollectionView.delegate = self
    hourlyCollectionView.dataSource = self
    
    hourlyCollectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()  // 전체 영역 사용
    }
  }
  
  func configure(with forecasts: [HourlyForecast]) {
    self.forecasts = forecasts
    hourlyCollectionView.reloadData()
  }
}

// MARK: - Collection View DataSource & Delegate
extension HourlyForecastView: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return forecasts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyForecastCell
    cell.configure(with: forecasts[indexPath.item])
    return cell
  }
}
