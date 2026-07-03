// Models/Message.swift
// HermesAgent - Message Model

import Foundation

enum MessageRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system
}

enum ContentBlock: Codable, Equatable {
    case text(String)
    case image(Data, String?) // image data + mime type
    case toolUse(String, [String: JSONValue]) // tool name + input
    case toolResult(String, String?) // tool use id + result text
    
    var text: String? {
        if case .text(let s) = self { return s }
        return nil
    }
    
    var isToolUse: Bool {
        if case .toolUse = self { return true }
        return false
    }
    
    var isToolResult: Bool {
        if case .toolResult = self { return true }
        return false
    }
}

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    var role: MessageRole
    var contentBlocks: [ContentBlock]
    var timestamp: Date
    var isStreaming: Bool = false
    var toolCalls: [ToolCall] = []
    
    init(
        id: UUID = UUID(),
        role: MessageRole,
        contentBlocks: [ContentBlock] = [],
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        toolCalls: [ToolCall] = []
    ) {
        self.id = id
        self.role = role
        self.contentBlocks = contentBlocks
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.toolCalls = toolCalls
    }
    
    var textContent: String {
        contentBlocks.compactMap { $0.text }.joined(separator: "\n")
    }
    
    var displayText: String {
        if isStreaming && role == .assistant {
            return textContent + " ▌"
        }
        return textContent
    }
}

struct ToolCall: Identifiable, Codable, Equatable {
    let id: UUID
    let toolName: String
    let input: [String: JSONValue]
    let status: ToolCallStatus
    var result: String?
    var startedAt: Date?
    var finishedAt: Date?
    
    init(
        id: UUID = UUID(),
        toolName: String,
        input: [String: JSONValue],
        status: ToolCallStatus = .pending,
        result: String? = nil,
        startedAt: Date? = nil,
        finishedAt: Date? = nil
    ) {
        self.id = id
        self.toolName = toolName
        self.input = input
        self.status = status
        self.result = result
        self.startedAt = startedAt
        self.finishedAt = finishedAt
    }
}

enum ToolCallStatus: String, Codable {
    case pending
    case running
    case completed
    case failed
    
    var displayText: String {
        switch self {
        case .pending: return "⏳ Pending"
        case .running: return "🔄 Running"
        case .completed: return "✅ Completed"
        case .failed: return "❌ Failed"
        }
    }
}

struct Conversation: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var messages: [Message]
    var systemPrompt: String?
    var createdAt: Date
    var updatedAt: Date
    var model: String
    var tokenCount: Int?
    var metadata: [String: String]
    
    init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        messages: [Message] = [],
        systemPrompt: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        model: String = "claude-sonnet-4-5-20250929",
        tokenCount: Int? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.systemPrompt = systemPrompt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
        self.tokenCount = tokenCount
        self.metadata = metadata
    }
    
    var previewText: String {
        messages.last?.displayText.prefix(80).description ?? "No messages yet"
    }
}

// JSONValue helper for Codable dynamic dictionaries
enum JSONValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case object([String: JSONValue])
    case array([JSONValue])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(String.self) { self = .string(v); return }
        if let v = try? container.decode(Double.self) { self = .number(v); return }
        if let v = try? container.decode(Bool.self) { self = .bool(v); return }
        if container.decodeNil() { self = .null; return }
        if let v = try? container.decode([String: JSONValue].self) { self = .object(v); return }
        if let v = try? container.decode([JSONValue].self) { self = .array(v); return }
        throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode JSONValue"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .number(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        case .null: try container.encodeNil()
        case .object(let v): try container.encode(v)
        case .array(let v): try container.encode(v)
        }
    }
}