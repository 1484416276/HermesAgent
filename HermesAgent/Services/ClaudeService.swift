// Services/ClaudeService.swift
// HermesAgent - Claude API Service

import Foundation

struct ClaudeAPIConfiguration: Codable {
    var apiKey: String
    var baseURL: String = "https://api.anthropic.com"
    var model: String = "claude-sonnet-4-5-20250929"
    var maxTokens: Int = 4096
    var temperature: Double = 1.0
    var topP: Double = 0.999
    var topK: Int = 250
    var systemPrompt: String = """
    You are HermesAgent, an intelligent assistant running on iPad.
    You can use tools to accomplish complex tasks. Always be helpful and thorough.
    """
    
    var headers: [String: String] {
        [
            "x-api-key": apiKey,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
            "anthropic-dangerous-direct-browser-access": "true"
        ]
    }
}

struct ClaudeMessage: Codable {
    let role: String
    let content: [ClaudeContentBlock]
    
    init(role: String, content: [ClaudeContentBlock]) {
        self.role = role
        self.content = content
    }
}

struct ClaudeContentBlock: Codable {
    let type: String
    let text: String?
    let id: String?
    let name: String?
    let input: [String: JSONValue]?
    let toolUseId: String?
    let content: [ClaudeContentBlock]?
    
    enum CodingKeys: String, CodingKey {
        case type, text, id, name, input, content
        case toolUseId = "tool_use_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        text = try? container.decode(String.self, forKey: .text)
        id = try? container.decode(String.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        input = try? container.decode([String: JSONValue].self, forKey: .input)
        toolUseId = try? container.decode(String.self, forKey: .toolUseId)
        content = try? container.decode([ClaudeContentBlock].self, forKey: .content)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try? container.encode(text, forKey: .text)
        try? container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        try? container.encode(input, forKey: .input)
        try? container.encode(toolUseId, forKey: .toolUseId)
        try? container.encode(content, forKey: .content)
    }
}

struct ClaudeRequest: Codable {
    let model: String
    let maxTokens: Int
    let system: String?
    let messages: [ClaudeMessage]
    let temperature: Double?
    let topP: Double?
    let topK: Int?
    let tools: [ClaudeToolDefinition]?
    let stream: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case model, messages, system, tools, stream
        case maxTokens = "max_tokens"
        case temperature
        case topP = "top_p"
        case topK = "top_k"
    }
}

struct ClaudeToolDefinition: Codable, Equatable {
    let name: String
    let description: String
    let inputSchema: JSONValue
    
    enum CodingKeys: String, CodingKey {
        case name, description
        case inputSchema = "input_schema"
    }
    
    init(name: String, description: String, inputSchema: [String: Any]) throws {
        self.name = name
        self.description = description
        let data = try JSONSerialization.data(withJSONObject: inputSchema)
        self.inputSchema = try JSONDecoder().decode(JSONValue.self, from: data)
    }
}

struct ClaudeStreamEvent: Decodable {
    let type: String
    let index: Int?
    let delta: Delta?
    let contentBlock: ClaudeContentBlock?
    let message: ClaudeResponse?
    
    enum CodingKeys: String, CodingKey {
        case type, index, delta
        case contentBlock = "content_block"
        case message
    }
    
    struct Delta: Decodable {
        let type: String
        let text: String?
        let partialJson: String?
        let stopReason: String?
        
        enum CodingKeys: String, CodingKey {
            case type, text
            case partialJson = "partial_json"
            case stopReason = "stop_reason"
        }
    }
}

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ClaudeContentBlock]
    let model: String
    let stopReason: String?
    let usage: Usage?
    
    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model, usage
        case stopReason = "stop_reason"
    }
}

struct Usage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

@MainActor
class ClaudeService: ObservableObject {
    static let shared = ClaudeService()
    
    @Published var configuration = ClaudeAPIConfiguration(
        apiKey: "",
        model: "claude-sonnet-4-5-20250929"
    )
    
    @Published var isConnected = false
    @Published var currentTask: String?
    
    private let session: URLSession
    private var streamTask: Task<Void, Never>?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        session = URLSession(configuration: config)
        loadConfiguration()
    }
    
    // MARK: - Configuration
    func loadConfiguration() {
        if let data = UserDefaults.standard.data(forKey: "claudeConfig"),
           let config = try? JSONDecoder().decode(ClaudeAPIConfiguration.self, from: data) {
            configuration = config
        }
    }
    
    func saveConfiguration() {
        if let data = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.set(data, forKey: "claudeConfig")
        }
    }
    
    // MARK: - API Methods
    func sendMessage(
        messages: [Message],
        tools: [ClaudeToolDefinition]? = nil,
        systemPrompt: String? = nil
    ) async throws -> ClaudeResponse {
        let claudeMessages = messages.map { msg in
            ClaudeMessage(
                role: msg.role.rawValue,
                content: msg.contentBlocks.compactMap { block in
                    switch block {
                    case .text(let text):
                        return ClaudeContentBlock(type: "text", text: text, id: nil, name: nil, input: nil, toolUseId: nil, content: nil)
                    case .toolUse(let name, let input):
                        return ClaudeContentBlock(type: "tool_use", text: nil, id: UUID().uuidString, name: name, input: input, toolUseId: nil, content: nil)
                    case .toolResult(let id, let result):
                        return ClaudeContentBlock(type: "tool_result", text: result, id: nil, name: nil, input: nil, toolUseId: id, content: nil)
                    default:
                        return nil
                    }
                }
            )
        }
        
        let request = ClaudeRequest(
            model: configuration.model,
            maxTokens: configuration.maxTokens,
            system: systemPrompt ?? configuration.systemPrompt,
            messages: claudeMessages,
            temperature: configuration.temperature,
            topP: configuration.topP,
            topK: configuration.topK,
            tools: tools,
            stream: false
        )
        
        let url = URL(string: "\(configuration.baseURL)/v1/messages")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = configuration.headers
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorText)
        }
        
        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        return claudeResponse
    }
    
    func streamMessage(
        messages: [Message],
        tools: [ClaudeToolDefinition]? = nil,
        systemPrompt: String? = nil,
        onTextDelta: @escaping (String) -> Void,
        onToolUse: @escaping (ClaudeContentBlock) -> Void,
        onComplete: @escaping (ClaudeResponse) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        streamTask?.cancel()
        streamTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let claudeMessages = messages.map { msg in
                    ClaudeMessage(
                        role: msg.role.rawValue,
                        content: msg.contentBlocks.compactMap { block in
                            switch block {
                            case .text(let text):
                                return ClaudeContentBlock(type: "text", text: text, id: nil, name: nil, input: nil, toolUseId: nil, content: nil)
                            case .toolUse(let name, let input):
                                return ClaudeContentBlock(type: "tool_use", text: nil, id: UUID().uuidString, name: name, input: input, toolUseId: nil, content: nil)
                            case .toolResult(let id, let result):
                                return ClaudeContentBlock(type: "tool_result", text: result, id: nil, name: nil, input: nil, toolUseId: id, content: nil)
                            default:
                                return nil
                            }
                        }
                    )
                }
                
                let request = ClaudeRequest(
                    model: configuration.model,
                    maxTokens: configuration.maxTokens,
                    system: systemPrompt ?? configuration.systemPrompt,
                    messages: claudeMessages,
                    temperature: configuration.temperature,
                    topP: configuration.topP,
                    topK: configuration.topK,
                    tools: tools,
                    stream: true
                )
                
                let url = URL(string: "\(configuration.baseURL)/v1/messages")!
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "POST"
                urlRequest.allHTTPHeaderFields = configuration.headers
                urlRequest.httpBody = try JSONEncoder().encode(request)
                
                let (stream, _) = try await session.bytes(for: urlRequest)
                
                var fullContent: [ClaudeContentBlock] = []
                var currentToolUseBlock: ClaudeContentBlock?
                
                for try await line in stream.lines {
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.hasPrefix("data: ") else { continue }
                    let jsonString = String(trimmed.dropFirst(6))
                    guard let data = jsonString.data(using: .utf8) else { continue }
                    
                    do {
                        let event = try JSONDecoder().decode(ClaudeStreamEvent.self, from: data)
                        
                        switch event.type {
                        case "content_block_start":
                            if let block = event.contentBlock {
                                fullContent.append(block)
                                if block.type == "tool_use" {
                                    currentToolUseBlock = block
                                    onToolUse(block)
                                }
                            }
                            
                        case "content_block_delta":
                            if let delta = event.delta, delta.type == "text_delta", let text = delta.text {
                                onTextDelta(text)
                            }
                            
                        case "message_stop":
                            // Build complete response
                            let response = ClaudeResponse(
                                id: UUID().uuidString,
                                type: "message",
                                role: "assistant",
                                content: fullContent,
                                model: configuration.model,
                                stopReason: nil,
                                usage: nil
                            )
                            onComplete(response)
                            
                        default:
                            break
                        }
                    } catch {
                        // Skip unparseable lines
                    }
                }
            } catch {
                onError(error)
            }
        }
    }
    
    func cancelStream() {
        streamTask?.cancel()
        streamTask = nil
    }
    
    // MARK: - Connection Test
    func testConnection() async -> Bool {
        do {
            let testMessage = Message(role: .user, contentBlocks: [.text("Hi")])
            _ = try await sendMessage(messages: [testMessage], maxTokens: 10)
            isConnected = true
            return true
        } catch {
            isConnected = false
            return false
        }
    }
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code, let message):
            return "HTTP Error \(code): \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cancelled:
            return "Request cancelled"
        }
    }
}