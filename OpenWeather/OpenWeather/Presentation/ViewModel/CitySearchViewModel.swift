//
//  CitySearchViewModel.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/5/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol CitySearchViewModelProtocol {
  func transform(input: CitySearchViewModel.Input) -> CitySearchViewModel.Output
}

final class CitySearchViewModel: CitySearchViewModelProtocol {
  private let cityListUseCase: CityListUseCaseProtocol
  private let disposeBag = DisposeBag()
  
  private let citiesRelay = BehaviorRelay<[City]>(value: [])
  private let selectedCityRelay = BehaviorRelay<City>(value: City.default)
  private let errorRelay = PublishRelay<Error>()
  
  init(cityListUseCase: CityListUseCaseProtocol) {
    self.cityListUseCase = cityListUseCase
  }
  
  // 현재 선택된 도시에 대한 읽기 전용 접근자
  var currentSelectedCity: City {
    return selectedCityRelay.value
  }
  
  // MARK: - Input (Event -> VM)
  public struct Input {
    let viewWillAppear: Observable<Void>
    let searchText: Observable<String>
    let citySelected: Observable<IndexPath>
  }
  
  // MARK: - Ouput (Data -> VC)
  public struct Output {
    let cities: Observable<[City]>
    let selectedCity: Observable<City>
    let error: Observable<Error>
  }
  
  // MARK: - Transform (Input -> Output)
  public func transform(input: Input) -> Output {
    
    // viewWillAppear 시 초기 데이터 로드
    input.viewWillAppear
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let cities = self.cityListUseCase.getCities()
        self.citiesRelay.accept(cities)
      })
      .disposed(by: disposeBag)
    
    // 검색어 입력 시 필터링
    input.searchText
      .distinctUntilChanged()
      .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(onNext: { [weak self] searchText in
        guard let self = self else { return }
        let filteredCities = searchText.isEmpty ?
        self.cityListUseCase.getCities() :
        self.cityListUseCase.searchCities(name: searchText)
        self.citiesRelay.accept(filteredCities)
      })
      .disposed(by: disposeBag)
    
    // 도시 선택 시 처리
    input.citySelected
      .withLatestFrom(citiesRelay) { indexPath, cities in
        return cities[indexPath.row]
      }
      .bind(to: selectedCityRelay)
      .disposed(by: disposeBag)
    
    return Output(
      cities: citiesRelay.asObservable(),
      selectedCity: selectedCityRelay.asObservable(),
      error: errorRelay.asObservable()
    )
  }
}



