import Foundation
import Alamofire
import CoreLocation

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct Current: Codable {
    let temp_c: Double
    let condition: Condition
    let humidity: Int
    let wind_kph: Double
    let wind_dir: String
    let pressure_mb: Double
    let feelslike_c: Double
}

struct Condition: Codable {
    let text: String
    let icon: String
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let date_epoch: Int
    let day: Day
    let hour: [Hour]
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let maxwind_kph: Double
    let totalprecip_mm: Double
    let avghumidity: Double
    let condition: Condition
}

struct Hour: Codable {
    let time: String
    let temp_c: Double
    let condition: Condition
    let wind_kph: Double
    let humidity: Int
}

class WeatherAPI {
    private let deepSeekAPI: DeepSeekAPI
    
    init() {
        self.deepSeekAPI = DeepSeekAPI()
    }
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let prompt = """
        请获取以下坐标位置的天气信息，并以JSON格式返回。需要包含未来7天的天气预报数据：
        纬度：\(latitude)
        经度：\(longitude)
        
        请按照以下JSON格式返回，forecastday 数组必须包含7天的数据：
        {
            "location": {
                "name": "城市名称",
                "region": "地区",
                "country": "国家",
                "lat": 纬度,
                "lon": 经度,
                "localtime": "当地时间"
            },
            "current": {
                "temp_c": 当前温度,
                "condition": {
                    "text": "天气状况描述",
                    "icon": "天气图标URL"
                },
                "humidity": 湿度百分比,
                "wind_kph": 风速,
                "wind_dir": "风向",
                "pressure_mb": 气压,
                "feelslike_c": 体感温度
            },
            "forecast": {
                "forecastday": [
                    {
                        "date": "今天日期",
                        "date_epoch": 今天时间戳,
                        "day": {
                            "maxtemp_c": 最高温度,
                            "mintemp_c": 最低温度,
                            "avgtemp_c": 平均温度,
                            "maxwind_kph": 最大风速,
                            "totalprecip_mm": 降水量,
                            "avghumidity": 平均湿度,
                            "condition": {
                                "text": "天气状况描述",
                                "icon": "天气图标URL"
                            }
                        },
                        "hour": [
                            {
                                "time": "时间",
                                "temp_c": 温度,
                                "condition": {
                                    "text": "天气状况描述",
                                    "icon": "天气图标URL"
                                },
                                "wind_kph": 风速,
                                "humidity": 湿度
                            }
                        ]
                    }
                ]
            }
        }
        
        注意：
        1. forecastday 数组必须包含7天的数据
        2. 日期从今天开始，依次是明天、后天等
        3. 每天的数据格式必须完全相同
        4. 温度、湿度等数值要合理
        5. 天气描述要符合实际情况
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "你是一个专业的天气信息提供者，请提供准确的天气数据。你必须提供未来7天的天气预报数据，数据要合理且符合实际情况。"],
            ["role": "user", "content": prompt]
        ]
        
        deepSeekAPI.fetchChatResponse(messages: messages, responseFormat: ["type": "json_object"]) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonData = response.data(using: .utf8) {
                        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: jsonData)
                        completion(.success(weatherResponse))
                    } else {
                        completion(.failure(NSError(domain: "WeatherAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchWeatherByCity(city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let prompt = """
        请获取以下城市的天气信息，并以JSON格式返回。需要包含未来7天的天气预报数据：
        城市：\(city)
        
        请按照以下JSON格式返回，forecastday 数组必须包含7天的数据：
        {
            "location": {
                "name": "城市名称",
                "region": "地区",
                "country": "国家",
                "lat": 纬度,
                "lon": 经度,
                "localtime": "当地时间"
            },
            "current": {
                "temp_c": 当前温度,
                "condition": {
                    "text": "天气状况描述",
                    "icon": "天气图标URL"
                },
                "humidity": 湿度百分比,
                "wind_kph": 风速,
                "wind_dir": "风向",
                "pressure_mb": 气压,
                "feelslike_c": 体感温度
            },
            "forecast": {
                "forecastday": [
                    {
                        "date": "今天日期",
                        "date_epoch": 今天时间戳,
                        "day": {
                            "maxtemp_c": 最高温度,
                            "mintemp_c": 最低温度,
                            "avgtemp_c": 平均温度,
                            "maxwind_kph": 最大风速,
                            "totalprecip_mm": 降水量,
                            "avghumidity": 平均湿度,
                            "condition": {
                                "text": "天气状况描述",
                                "icon": "天气图标URL"
                            }
                        },
                        "hour": [
                            {
                                "time": "时间",
                                "temp_c": 温度,
                                "condition": {
                                    "text": "天气状况描述",
                                    "icon": "天气图标URL"
                                },
                                "wind_kph": 风速,
                                "humidity": 湿度
                            }
                        ]
                    }
                ]
            }
        }
        
        注意：
        1. forecastday 数组必须包含7天的数据
        2. 日期从今天开始，依次是明天、后天等
        3. 每天的数据格式必须完全相同
        4. 温度、湿度等数值要合理
        5. 天气描述要符合实际情况
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "你是一个专业的天气信息提供者，请提供准确的天气数据。你必须提供未来7天的天气预报数据，数据要合理且符合实际情况。"],
            ["role": "user", "content": prompt]
        ]
        
        deepSeekAPI.fetchChatResponse(messages: messages, responseFormat: ["type": "json_object"]) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonData = response.data(using: .utf8) {
                        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: jsonData)
                        completion(.success(weatherResponse))
                    } else {
                        completion(.failure(NSError(domain: "WeatherAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
} 