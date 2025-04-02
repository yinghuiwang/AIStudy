//
//  ConfigManager.swift
//  AIStudy
//
//  Created by mark on 2025/4/1.
//

import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    
    private init() {
        loadConfig()
    }
    
    private func loadConfig() {
        var path = Bundle.main.path(forResource: "DefaultConfig_Mark", ofType: "plist")
        if path == nil {
            path = Bundle.main.path(forResource: "DefaultConfig", ofType: "plist")
        }
        guard let configPath = path else {
            debugPrint("Config file not found")
            return
        }
        
        if let dict = NSDictionary(contentsOfFile: configPath) as? [String: Any] {
            self.config = dict
        }
    }
    
    private var config: [String: Any] = [:]
    
    func getConfigValue(forKey key: String) -> Any? {
        return config[key]
    }
}
