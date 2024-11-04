//
//  SearchView.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/1/24.
//

import UIKit
import SnapKit

public protocol CitySelectionDelegate: AnyObject {
  func didSelectCity(_ city: City)
}

// MARK: - Main/View/CityListSearchViewController.swift
import UIKit
import SnapKit

final class CityListSearchViewController: UIViewController {
  // MARK: - Properties
  private let useCase: CityListUseCaseProtocol
  private var cities: [City] = []
  weak var delegate: CitySelectionDelegate?
  
  // MARK: - UI Components
  private lazy var closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "xmark"), for: .normal)
    button.tintColor = .white
    button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private lazy var searchBar = makeSearchBar()
  private lazy var tableView = makeTableView()
  
  // MARK: - Initialization
  init(useCase: CityListUseCaseProtocol) {
    self.useCase = useCase
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .fullScreen
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    loadCities()
  }
  
  // MARK: - UI Setup
  private func setupUI() {
    setupBackground()
    setupSubviews()
    setupConstraints()
  }
  
  private func setupBackground() {
    view.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
  }
  
  private func setupSubviews() {
    view.addSubview(closeButton)
    view.addSubview(searchBar)
    view.addSubview(tableView)
  }
  
  private func setupConstraints() {
    closeButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.width.height.equalTo(24)
    }
    
    searchBar.snp.makeConstraints { make in
      make.top.equalTo(closeButton.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(56)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  // MARK: - Actions
  @objc private func closeButtonTapped() {
    dismiss(animated: true)
  }
  
  func makeSearchBar() -> UISearchBar {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.backgroundImage = UIImage()
    searchBar.delegate = self
    searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.3)
    searchBar.searchTextField.textColor = .white
    searchBar.tintColor = .white
    searchBar.barTintColor = .clear
    return searchBar
  }
  
  func makeTableView() -> UITableView {
    let tableView = UITableView()
    tableView.backgroundColor = .clear
    tableView.register(CityTableViewCell.self, forCellReuseIdentifier: "CityCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .singleLine
    tableView.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 26, right: 0)
    tableView.separatorColor = .white
    
    
    return tableView
  }
  
}

// MARK: - Data Loading
private extension CityListSearchViewController {
  func loadCities() {
    cities = useCase.getCities()
    tableView.reloadData()
  }
  
  func searchCities(with query: String) {
    cities = query.isEmpty ? useCase.getCities() : useCase.searchCities(name: query)
    tableView.reloadData()
  }
}

// MARK: - UITableViewDataSource
extension CityListSearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cities.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityTableViewCell else {
      return UITableViewCell()
    }
    
    cell.configure(with: cities[indexPath.row])
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CityListSearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedCity = cities[indexPath.row]
    delegate?.didSelectCity(selectedCity)
  }
}

// MARK: - UISearchBarDelegate
extension CityListSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchCities(with: searchText)
  }
}
