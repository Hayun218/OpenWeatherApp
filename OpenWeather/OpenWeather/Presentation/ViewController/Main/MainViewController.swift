import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

final class MainViewController: UIViewController {
  // MARK: - Properties
  private let viewModel: MainViewModel
  private let citySearchViewModel: CitySearchViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  private let searchButton = SearchButton()
  private let weatherHeader = WeatherHeaderView()
  private let hourlyForecast = HourlyForecastView()
  private let dailyForecast = DailyForecastView()
  private let metricsView = WeatherMetricsView()
  private let mapView: MKMapView = {
    let map = MKMapView()
    map.layer.cornerRadius = 15
    map.clipsToBounds = true
    return map
  }()
  private let loadingIndicator = UIActivityIndicatorView(style: .large)
  
  // Rx Subject for refresh
  private let refreshTrigger = PublishSubject<Void>()
  
  // MARK: - Init
  init(viewModel: MainViewModel, citySearchViewModel: CitySearchViewModel) {
    self.viewModel = viewModel
    self.citySearchViewModel = citySearchViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
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
    
    [weatherHeader, hourlyForecast, dailyForecast, mapView, metricsView]
      .forEach { contentView.addSubview($0) }
    
    setupConstraints(scrollView: scrollView, contentView: contentView)
  }
  
  private func setupConstraints(scrollView: UIScrollView, contentView: UIView) {
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
      make.height.equalTo(106)
    }
    
    dailyForecast.snp.makeConstraints { make in
      make.top.equalTo(hourlyForecast.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(280)
    }
    
    
    mapView.snp.makeConstraints { make in
      make.top.equalTo(dailyForecast.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(200)  // 맵 높이 설정
    }
    
    metricsView.snp.makeConstraints { make in
      make.top.equalTo(mapView.snp.bottom).offset(20)  // 수정
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(100)
      make.bottom.equalToSuperview().offset(-20)
    }
    
    loadingIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func bindViewModel() {
    // Input 설정
    let viewWillAppearObservable = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
      .map { _ in () }
      .asObservable()
    
    let input = MainViewModel.Input(
      viewWillAppear: viewWillAppearObservable,
      refreshTrigger: refreshTrigger.asObservable()
    )
    
    // Output 바인딩
    let output = viewModel.transform(input: input)
    
    // 날씨 상태 구독
    output.weatherState
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        self?.handleWeatherState(state)
      })
      .disposed(by: disposeBag)
    
    // 에러 메시지 구독
    output.errorMessage
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] message in
        self?.showError(message)
      })
      .disposed(by: disposeBag)
    
    // Search Button 바인딩
    searchButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.showCitySearch()
      })
      .disposed(by: disposeBag)
    // 맵 바인딩
    
    output.coordinates
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] coordinate in
        self?.updateMapLocation(coordinate)
      })
      .disposed(by: disposeBag)
    
  }
  
  private func updateMapLocation(_ coordinate: Coordinate) {
    // 좌표로 지도 중심 이동
    let location = CLLocationCoordinate2D(
      latitude: coordinate.lat,
      longitude: coordinate.lon
    )
    let region = MKCoordinateRegion(
      center: location,
      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    mapView.setRegion(region, animated: true)
    
    // 기존 핀 제거
    mapView.removeAnnotations(mapView.annotations)
    
    // 새로운 핀 추가
    let annotation = MKPointAnnotation()
    annotation.coordinate = location
    mapView.addAnnotation(annotation)
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
    
    print(weather.hourlyForecast)
    weatherHeader.configure(with: weather)
    hourlyForecast.configure(with: weather.hourlyForecast)
    dailyForecast.configure(with: weather.dailyForecast)
    metricsView.configure(
      humidity: weather.todayForecast.averageHumidity,
      clouds: Int(Double(weather.todayForecast.averageClouds)),
      windSpeed: weather.todayForecast.averageWindSpeed
    )
  }
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  // MARK: - Navigation
  private func showCitySearch() {
    let citySearchVC = CitySearchViewController(
      viewModel: citySearchViewModel
    )
    present(citySearchVC, animated: true)
  }
}
