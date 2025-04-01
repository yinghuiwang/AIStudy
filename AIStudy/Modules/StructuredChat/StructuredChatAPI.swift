//
//  StructuredChatAPI.swift
//  AIStudy
//
//  Created by mark on 2025/3/27.
//

import Foundation
import Alamofire

struct StructuredChatRequest: Encodable {
    let model: String
    let messages: [[String: String]]
    let stream: Bool
    let response_format: [String: String]
}

struct StructuredChatAPI {
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    private var apiKey: String
    
    init() {
        let apiKey = ConfigManager.shared.getConfigValue(forKey: "deepseek_api_key") as? String
        assert(apiKey != nil, "请在 Config.plist 文件中配置 `deepseek_api_key`")
        self.apiKey = apiKey ?? ""
    }
    
    func fetchStructuredResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let requestBody = StructuredChatRequest(
            model: "deepseek-chat",
            messages: [
                ["role": "system", "content": "你是一个JSON数据生成器。你只能返回符合指定结构的JSON数据，不要包含任何其他信息或解释。"],
                ["role": "user", "content": prompt]
            ],
            stream: false,
            response_format: ["type": "json_object"]
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
                } else {
                    completion(.failure(NSError(domain: "StructuredChatAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
} 