// Services/SettingsStore.swift
// HermesAgent - Settings Store

import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @Published var apiKey: String = "" {
        didSet { save() }
    }
    
    @Published var model: String = "claude-sonnet-4-5-20250929" {
        didSet { save() }
    }
    
    @Published var maxTokens: Int = 4096 {
        didSet { save() }
    }
    
    @Published var temperature: Double = 1.0 {
        didSet { save() }
    }
    
    @Published var fontSize: Double = 16 {
        didSet { save() }
    }
    
    @Published var fontFamily: String = "SF Pro" {
        didSet { save() }
    }
    
    @Published var colorScheme: ColorScheme? = nil {
        didSet { save() }
    }
    
    @Published var streamEnabled: Bool = true {
        didSet { save() }
    }
    
    @Published var soundEnabled: Bool = true {
        didSet { save() }
    }
    
    @Published var hapticEnabled: Bool = true {
        didSet { save() }
    }
    
    private let settingsKey = "hermesSettings"
    
    private init() {
        load()
    }
    
    private func save() {
        let dict: [String: Any] = [
            "apiKey": apiKey,
            "model": model,
            "maxTokens": maxTokens,
            "temperature": temperature,
            "fontSize": fontSize,
            "fontFamily": fontFamily,
            "colorSchemeRaw": colorScheme == .dark ? "dark" : (colorScheme == .light ? "light" : "auto"),
            "streamEnabled": streamEnabled,
            "soundEnabled": soundEnabled,
            "hapticEnabled": hapticEnabled
        ]
        UserDefaults.standard.set(dict, forKey: settingsKey)
    }
    
    private func load() {
        guard let dict = UserDefaults.standard.dictionary(forKey: settingsKey) else { return }
        
        apiKey = dict["apiKey"] as? String ?? ""
        model = dict["model"] as? String ?? "claude-sonnet-4-5-20250929"
        maxTokens = dict["maxTokens"] as? Int ?? 4096
        temperature = dict["temperature"] as? Double ?? 1.0
        fontSize = dict["fontSize"] as? Double ?? 16
        fontFamily = dict["fontFamily"] as? String ?? "SF Pro"
        streamEnabled = dict["streamEnabled"] as? Bool ?? true
        soundEnabled = dict["soundEnabled"] as? Bool ?? true
        hapticEnabled = dict["hapticEnabled"] as? Bool ?? true
        
        if let scheme = dict["colorSchemeRaw"] as? String {
            colorScheme = scheme == "dark" ? .dark : (scheme == "light" ? .light : nil)
        }
    }
    
    var availableModels: [String] {
        [
            "claude-sonnet-4-5-20250929",
            "claude-3-5-sonnet-20240620",
            "claude-3-opus-20240229",
            "claude-3-haiku-20240307"
        ]
    }
}