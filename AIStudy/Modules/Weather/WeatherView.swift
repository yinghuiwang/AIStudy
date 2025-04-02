import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var isLoading = false
    @Published var error: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isLoading = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        isLoading = false
    }
}

struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherResponse?
    @State private var isLoading = false
    @State private var error: String?
    @State private var cityName = ""
    @State private var isSearching = false
    @FocusState private var isTextFieldFocused: Bool
    
    private let weatherAPI = WeatherAPI()
    
    var body: some View {
        VStack(spacing: 16) {
            // 城市选择区域
            HStack {
                TextField("输入城市名称", text: $cityName)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: searchCity) {
                    Text("搜索")
                }
                .buttonStyle(.bordered)
                .padding(.trailing)
            }
            
            // 城市名称显示
            if let weather = weatherData {
                Text(weather.location.name)
                    .font(.title)
                    .bold()
                    .padding(.top)
            }
            
            if locationManager.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("正在获取位置信息...")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            } else if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("正在获取天气数据...")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let weather = weatherData {
                ScrollView {
                    VStack(spacing: 20) {
                        // 当前天气
                        CurrentWeatherView(current: weather.current)
                        
                        // 7天预报
                        ForEach(weather.forecast.forecastday, id: \.date) { day in
                            DailyForecastView(forecastDay: day)
                        }
                    }
                    .padding()
                }
            } else {
                Text("暂无天气数据")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationTitle("天气")
        .onAppear {
            locationManager.requestLocation()
            if let location = locationManager.location {
                fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
    }
    
    private func fetchWeather(latitude: Double, longitude: Double) {
        isLoading = true
        error = nil
        
        weatherAPI.fetchWeather(latitude: latitude, longitude: longitude) { result in
            isLoading = false
            switch result {
            case .success(let response):
                weatherData = response
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }
    
    private func searchCity() {
        let city = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else { return }
        
        isLoading = true
        isTextFieldFocused = false
        error = nil
        
        weatherAPI.fetchWeatherByCity(city: city) { result in
            isLoading = false
            switch result {
            case .success(let response):
                weatherData = response
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }
}

struct CurrentWeatherView: View {
    let current: Current
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(current.temp_c))°C")
                .font(.system(size: 48, weight: .bold))
            
            Text(current.condition.text)
                .font(.title2)
            
            HStack(spacing: 20) {
                WeatherInfoItem(title: "湿度", value: "\(current.humidity)%")
                WeatherInfoItem(title: "风速", value: "\(Int(current.wind_kph)) km/h")
                WeatherInfoItem(title: "气压", value: "\(Int(current.pressure_mb)) mb")
                WeatherInfoItem(title: "体感", value: "\(Int(current.feelslike_c))°C")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DailyForecastView: View {
    let forecastDay: ForecastDay
    
    var body: some View {
        HStack {
            Text(formatDate(forecastDay.date))
                .frame(width: 100, alignment: .leading)
            
            AsyncImage(url: URL(string: "https:" + forecastDay.day.condition.icon)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 32, height: 32)
            
            Text(forecastDay.day.condition.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(Int(forecastDay.day.maxtemp_c))° / \(Int(forecastDay.day.mintemp_c))°")
                .frame(width: 100, alignment: .trailing)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct WeatherInfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .bold()
        }
    }
}

#Preview {
    NavigationView {
        WeatherView()
    }
} 
