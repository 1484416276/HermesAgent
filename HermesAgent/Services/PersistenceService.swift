// Services/PersistenceService.swift
// HermesAgent - Persistence Service

import Foundation

@MainActor
class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    private let conversationsKey = "hermesConversations"
    private let fileManager = FileManager.default
    
    private init() {}
    
    // MARK: - Save / Load
    func saveConversations(_ conversations: [Conversation]) {
        if let data = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(data, forKey: conversationsKey)
        }
    }
    
    func loadConversations() -> [Conversation] {
        guard let data = UserDefaults.standard.data(forKey: conversationsKey),
              let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return []
        }
        return conversations
    }
    
    // MARK: - Export / Import
    func exportConversations() -> Data? {
        let conversations = loadConversations()
        return try? JSONEncoder().encode(conversations)
    }
    
    func importConversations(from data: Data) -> Bool {
        guard let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return false
        }
        var existing = loadConversations()
        
        // Merge, avoiding duplicates
        for newConv in conversations {
            if !existing.contains(where: { $0.id == newConv.id }) {
                existing.append(newConv)
            }
        }
        
        saveConversations(existing)
        return true
    }
    
    // MARK: - Clear
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: conversationsKey)
    }
}