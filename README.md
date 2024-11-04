# OpenWeatherApp
2024 10월 아우토크립트 사전과제

## 개요
- 과제는 *OpenWeather API*를 이용하여 날씨를 보고자하는 리스트와 선택한 도시의 날씨를 보여주는 애플리케이션을 제작하는 것입니다.
- 본 과제를 공유 또는 게시하는 행위는 저작권법 위반에 해당할 수 있습니다.
 
[사전 과제]
# 아키텍처
l   Base MVVM
# 필수 라이브러리
l   Snapkit Alamofire → ('Moya' 등 다른 라이브러리를 사용하거나 라이브러리 자체를 사용하지 않아도 되나, ‘Alamofire’ 사용 권장)
l   RxSwift
l   Only Code (Storyboard X)
# 일정
l   5MD (1인 기준)
n   2024.11.01 ~ 2024.11.07
# 과제
화면은 총 2개로 이루어져 있습니다.
화면 플로우는 다음과 같습니다.
l   [Main 화면] → 최초 데이터 기준 “{"id":1839726,"name":"Asan","country":"KR","coord":{"lon":127.004173,"lat":36.783611}}”
l   [Main 화면]에서 Search영역을 선택 했을 경우 [Search 화면] Present
l   [Search 화면]에서 원하는 도시를 입력하여 선택 → [Search 화면] Dismiss → [Main 화면] 데이터 표출
l   [Search 화면]은 날씨를 보고 싶은 도시 리스트를 표출 및 검색이 가능합니다.
l   [Main 화면]은 선택한 도시의 날씨 정보를 확인 할 수 있습니다.
# API
자세한 내용은 공식 문서에서 확인하시길 바랍니다.
l   5일간 일기예보 → https://openweathermap.org/forecast5
