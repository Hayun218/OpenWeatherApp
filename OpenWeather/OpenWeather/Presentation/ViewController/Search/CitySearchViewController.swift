import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CitySearchViewController: UIViewController {
  // MARK: - Properties
  private let viewModel: CitySearchViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  private lazy var closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "xmark"), for: .normal)
    button.tintColor = .white
    return button
  }()
  
  private lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.backgroundImage = UIImage()
    searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.3)
    searchBar.searchTextField.textColor = .white
    searchBar.tintColor = .white
    searchBar.barTintColor = .clear
    return searchBar
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .clear
    tableView.register(CityTableViewCell.self, forCellReuseIdentifier: "CityCell")
    tableView.separatorStyle = .singleLine
    tableView.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 26, right: 0)
    tableView.separatorColor = .white
    return tableView
  }()
  
  // MARK: - Initialization
  init(viewModel: CitySearchViewModel) {
    self.viewModel = viewModel
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
    bindViewModel()
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
  
  // MARK: - Binding
  private func bindViewModel() {
    let viewWillAppearObservable = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
      .map { _ in () }
      .asObservable()
    
    let input = CitySearchViewModel.Input(
      viewWillAppear: viewWillAppearObservable,
      searchText: searchBar.rx.text.orEmpty.asObservable(),
      citySelected: tableView.rx.itemSelected.asObservable()
    )
    
    let output = viewModel.transform(input: input)
    
    
    // 도시 목록 바인딩
    output.cities
      .bind(to: tableView.rx.items(cellIdentifier: "CityCell", cellType: CityTableViewCell.self)) { _, city, cell in
        cell.configure(with: city)
      }
      .disposed(by: disposeBag)
    
    // 도시 선택 시 화면 닫기
    output.selectedCity
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 에러 처리
    output.error
      .subscribe(onNext: { [weak self] error in
        self?.showError(error)
      })
      .disposed(by: disposeBag)
    
    // 닫기 버튼 바인딩
    closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 키보드 처리
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] _ in
        self?.view.endEditing(true)
      })
      .disposed(by: disposeBag)
  }
  
  private func showError(_ error: Error) {
    let alert = UIAlertController(
      title: "Error",
      message: error.localizedDescription,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

