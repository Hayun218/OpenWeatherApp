// MARK: - Presentation/View/MainViewController.swift
import UIKit
import RxSwift
import SnapKit

final class MainViewController: UIViewController {
  // MARK: - Properties
  private let viewModel: MainViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  private let searchButton = SearchButton()
  private let weatherHeader = WeatherHeaderView()
  private let hourlyForecast = HourlyForecastView()
  private let dailyForecast = DailyForecastView()
  private let metricsView = WeatherMetricsView()
  private let loadingIndicator = UIActivityIndicatorView(style: .large)
  
  // MARK: - Initialization
  init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
    setupActions()
  }
  
  // MARK: - Setup
  private func setupUI() {
    view.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    view.addSubview(searchButton)
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    view.addSubview(loadingIndicator)
    
    [weatherHeader, hourlyForecast, dailyForecast, metricsView]
      .forEach { contentView.addSubview($0) }
    
    setupConstraints(scrollView: scrollView, contentView: contentView)
  }
  
  private func setupConstraints(scrollView: UIScrollView, contentView: UIView) {
    // 기존 제약 조건 유지
    searchButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(44)
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(searchButton.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    weatherHeader.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.leading.trailing.equalToSuperview()
    }
    
    hourlyForecast.snp.makeConstraints { make in
      make.top.equalTo(weatherHeader.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(100)
    }
    
    dailyForecast.snp.makeConstraints { make in
      make.top.equalTo(hourlyForecast.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(16)
    }
    
    metricsView.snp.makeConstraints { make in
      make.top.equalTo(dailyForecast.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(100)
      make.bottom.equalToSuperview().offset(-20)
    }
    
    loadingIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupBindings() {
    viewModel.weatherState
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        self?.handleWeatherState(state)
      })
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] message in
        self?.showError(message)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupActions() {
    searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
  }
  
  // MARK: - UI Updates
  private func handleWeatherState(_ state: LoadingState<CityWeather>) {
    switch state {
    case .idle:
      loadingIndicator.stopAnimating()
    case .loading:
      loadingIndicator.startAnimating()
    case .loaded(let weather):
      loadingIndicator.stopAnimating()
      updateUI(with: weather)
    case .error:
      loadingIndicator.stopAnimating()
    }
  }
  
  private func updateUI(with weather: CityWeather) {
    weatherHeader.configure(with: weather)
    hourlyForecast.configure(with: weather.hourlyForecast)
    dailyForecast.configure(with: weather.dailyForecast)
    metricsView.configure(
      humidity: weather.averageHumidity,
      clouds: Int(Double(weather.averageClouds)),
      windSpeed: weather.averageWindSpeed
    )
  }
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  // MARK: - Actions
  @objc private func searchButtonTapped() {
    let cityListVC = CityListSearchViewController(useCase: viewModel.getCityListUseCase())
    cityListVC.delegate = self
    cityListVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    present(cityListVC, animated: true)
  }
}

// MARK: - CitySelectionDelegate
extension MainViewController: CitySelectionDelegate {
  func didSelectCity(_ city: City) {
    dismiss(animated: true) {
      self.viewModel.fetchWeatherData(for: city)
    }
  }
}
