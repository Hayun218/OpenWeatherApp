//
//  SceneDelegate.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/1/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
      guard let windowScene = (scene as? UIWindowScene) else { return }
      
      // Repository & UseCase 초기화
      let network = WeatherNetwork(manager: NetworkManager())
      let repository = WeatherRepository(network: network)
      let weatherUseCase = CityWeatherUsecase(repository: repository)
      let cityRepository = CityRepository()
      let cityUsecase = CityListUseCase(repository: cityRepository)
      
      // City 초기화 및 ViewModel 생성
      Task {
          // City 데이터 초기화
          let result = await cityUsecase.initialize()
          
          await MainActor.run {
              // ViewModel 생성
              let citySearchViewModel = CitySearchViewModel(cityListUseCase: cityUsecase)
              let mainViewModel = MainViewModel(
                  weatherUseCase: weatherUseCase,
                  citySearchViewModel: citySearchViewModel
              )
              
              // ViewController 생성 및 설정
              let viewController = MainViewController(
                  viewModel: mainViewModel,
                  citySearchViewModel: citySearchViewModel
              )
              
              // Window 설정
              self.window = UIWindow(windowScene: windowScene)
              self.window?.rootViewController = viewController
              self.window?.makeKeyAndVisible()
          }
      }
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
  
}

