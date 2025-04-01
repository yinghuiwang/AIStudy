//
//  DeepSeekAPI.swift
//  AIStudy
//
//  Created by mark on 2025/3/27.
//

import Foundation
import Alamofire

struct DeepSeekRequest: Encodable {
    let model: String
    let messages: [[String: String]]
    let stream: Bool
}

struct DeepSeekAPI {
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    private var apiKey: String // 需要替换成你的 API Key
    
    init() {
        let apiKey = ConfigManager.shared.getConfigValue(forKey: "deepseek_api_key") as? String
        assert(apiKey != nil, "请在 Config.plist 文件中配置 `deepseek_api_key`")
        self.apiKey = apiKey ?? ""
    }
    
    func streamChatResponse(messages: [[String: String]]) -> AsyncStream<String> {
        return AsyncStream { continuation in
            let requestBody = DeepSeekRequest(
                model: "deepseek-chat",
                messages: messages,
                stream: true
            )
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ]
            
            // 发送流式请求
            AF.streamRequest(
                baseURL,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .responseStreamString { stream in
                switch stream.event {
                case let .stream(result):
                    switch result {
                    case let .success(lines):
                        // 打印收到的原始数据
                        print("Received Raw Data: \(lines)")
                        
                        let cleanedLines = lines
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "data:", with: "") // 去掉前缀
                            .components(separatedBy: "\n\n")
                        
                        for cleanedLine in cleanedLines {
                            
                            let isDone = cleanedLine == "[DONE]"
                            if isDone {
                                print("✅ 数据流解析完成")
                                continuation.finish()
                                return
                            }
                            
                            // 解析 JSON
                            guard let jsonData = cleanedLine.data(using: .utf8) else {
                                print("❌ JSON Data 转换失败: \(cleanedLine)")
                                return
                            }
                            
                            do {
                                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                    // 打印解析后的 JSON
                                    print("✅ Parsed JSON: \(json)")
                                    
                                    guard let choices = json["choices"] as? [[String: Any]] else {
                                        print("❌ JSON 缺少 `choices` 字段: \(json)")
                                        return
                                    }
                                    
                                    guard let content = choices.first?["delta"] as? [String: Any],
                                          let text = content["content"] as? String else {
                                        print("❌ `choices.delta.content` 解析失败: \(choices)")
                                        return
                                    }
                                    
                                    continuation.yield(text) // 逐步返回数据
                                }
                            } catch {
                                print("❌ JSON 解析失败: \(error.localizedDescription), 数据: \(cleanedLine)")
                            }
                        }
                    case let .failure(error):
                        print("❌ Stream Error: \(error)")
                        continuation.finish()
                    }
                    
                case .complete:
                    print("✅ 数据流解析完成")
                    continuation.finish()
                }
            }
        }
    }
    
    func fetchChatResponse(messages: [[String: String]], completion: @escaping (Result<String, Error>) -> Void) {
        let requestBody = DeepSeekRequest(
            model: "deepseek-chat",
            messages: messages,
            stream: false
        )
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        AF.request(
            baseURL,
            method: .post,
            parameters: requestBody,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        .responseJSON { response in
            switch response.result {
            case let .success(value):
                debugPrint("Response: \(value)")
                if let json = value as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let content = choices.first?["message"] as? [String: Any],
                   let text = content["content"] as? String {
                    debugPrint("Text: \(text)")
                    completion(.success(text))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
