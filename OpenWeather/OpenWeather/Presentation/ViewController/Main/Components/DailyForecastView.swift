//
//  DailyForecastView.swift
//  OpenWeather
//
//  Created by yun on 11/4/24.
//

import UIKit
import SnapKit

final class DailyForecastView: UIView {
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.isScrollEnabled = false
    tableView.register(DailyForecastCell.self, forCellReuseIdentifier: "DailyCell")
    return tableView
  }()
  
  private var forecasts: [DailyForecast] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    backgroundColor = .white.withAlphaComponent(0.3)
    layer.cornerRadius = 10
    
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }
  }
  
  func configure(with forecasts: [DailyForecast]) {
    self.forecasts = forecasts
    tableView.reloadData()
  }
}

// MARK: - TableView DataSource & Delegate
extension DailyForecastView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return forecasts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell", for: indexPath) as! DailyForecastCell
    cell.configure(with: forecasts[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
