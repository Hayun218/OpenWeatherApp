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
  private let mapView: MKMapView = {
    let map = MKMapView()
    map.layer.cornerRadius = 15
    map.clipsToBounds = true
    return map
  }()
  private let loadingIndicator = UIActivityIndicatorView(style: .large)
  private let backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.alpha = 0.7
    return imageView
  }()
  
  // Metrics Components
  private let humidityView = MetricItemView()
  private let cloudsView = MetricItemView()
  private let windSpeedView = MetricItemView()
  
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
    view.addSubview(backgroundImageView)
    backgroundImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    view.addSubview(searchButton)
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    view.addSubview(loadingIndicator)
    
    [weatherHeader, hourlyForecast, dailyForecast, mapView,
     humidityView, cloudsView, windSpeedView].forEach {
      contentView.addSubview($0)
    }
    
    setupConstraints(scrollView: scrollView, contentView: contentView)
  }
  
  private func setupConstraints(scrollView: UIScrollView, contentView: UIView) {
    searchButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
      make.height.equalTo(44)
    }
    
    
    
    loadingIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
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
      make.height.equalTo(200)
    }
    
    let metricWidth = (view.frame.width - 42) / 2
    
    humidityView.snp.makeConstraints { make in
      make.top.equalTo(mapView.snp.bottom).offset(20)
      make.leading.equalToSuperview().inset(16)
      make.width.equalTo(metricWidth)
      make.height.equalTo(metricWidth-20)
    }
    
    cloudsView.snp.makeConstraints { make in
      make.top.equalTo(humidityView)
      make.leading.equalTo(humidityView.snp.trailing).offset(20)
      make.trailing.equalToSuperview().inset(16)
      make.width.height.equalTo(humidityView)
    }
    
    windSpeedView.snp.makeConstraints { make in
      make.top.equalTo(humidityView.snp.bottom).offset(20)
      make.leading.equalToSuperview().inset(16)
      make.width.height.equalTo(humidityView)
      make.bottom.equalToSuperview().offset(-20)
    }
  }
  
  private func bindViewModel() {
    let viewWillAppearObservable = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
      .map { _ in () }
      .asObservable()
    
    let input = MainViewModel.Input(
      viewWillAppear: viewWillAppearObservable,
      refreshTrigger: refreshTrigger.asObservable()
    )
    
    let output = viewModel.transform(input: input)
    
    output.weatherState
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        self?.handleWeatherState(state)
      })
      .disposed(by: disposeBag)
    
    output.errorMessage
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] message in
        self?.showError(message)
      })
      .disposed(by: disposeBag)
    
    searchButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.showCitySearch()
      })
      .disposed(by: disposeBag)
    
    output.coordinates
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] coordinate in
        self?.updateMapLocation(coordinate)
      })
      .disposed(by: disposeBag)
    
    output.background
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] image in
        UIView.animate(withDuration: 0.3) {
          if let image = image {
            self?.backgroundImageView.image = image
            self?.backgroundImageView.backgroundColor = .clear
          } else {
            self?.backgroundImageView.image = nil
            self?.backgroundImageView.backgroundColor = UIColor(hexCode: "6A92C4")
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func updateMapLocation(_ coordinate: Coordinate) {
    let location = CLLocationCoordinate2D(
      latitude: coordinate.lat,
      longitude: coordinate.lon
    )
    let region = MKCoordinateRegion(
      center: location,
      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    mapView.setRegion(region, animated: true)
    
    mapView.removeAnnotations(mapView.annotations)
    
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
    weatherHeader.configure(with: weather)
    hourlyForecast.configure(with: weather.hourlyForecast)
    dailyForecast.configure(with: weather.dailyForecast)
    
    // Update metrics views
    humidityView.configure(
      title: "습도",
      value: "\(Int(round(weather.todayForecast.averageHumidity)))%"
    )
    cloudsView.configure(
      title: "구름",
      value: "\(weather.todayForecast.averageClouds)%"
    )
    windSpeedView.configure(
      title: "바람 속도",
      value: String(format: "%.2f m/s", weather.todayForecast.averageWindSpeed)
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
