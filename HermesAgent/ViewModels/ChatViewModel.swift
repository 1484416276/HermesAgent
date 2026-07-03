// ViewModels/ChatViewModel.swift
// HermesAgent - Chat ViewModel

import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let claudeService = ClaudeService.shared
    private let persistenceService = PersistenceService.shared
    
    init() {
        loadConversations()
        if conversations.isEmpty {
            newConversation()
        } else {
            currentConversation = conversations.first
        }
    }
    
    // MARK: - Conversation Management
    func newConversation() {
        let conversation = Conversation(
            title: "New Conversation",
            messages: []
        )
        conversations.insert(conversation, at: 0)
        currentConversation = conversation
        saveConversations()
    }
    
    func selectConversation(id: UUID) {
        currentConversation = conversations.first { $0.id == id }
    }
    
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        if currentConversation?.id == conversation.id {
            currentConversation = conversations.first
            if currentConversation == nil {
                newConversation()
            }
        }
        saveConversations()
    }
    
    // MARK: - Messaging
    func sendMessage(_ text: String) {
        guard !text.isEmpty, let conversation = currentConversation else { return }
        
        // Add user message
        let userMessage = Message(role: .user, contentBlocks: [.text(text)])
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()
        
        // Auto-generate title from first message
        if conversation.messages.count == 1 {
            conversation.title = String(text.prefix(50))
        }
        
        // Create assistant message placeholder
        let assistantMessage = Message(role: .assistant, contentBlocks: [.text("")], isStreaming: true)
        conversation.messages.append(assistantMessage)
        
        objectWillChange.send()
        isLoading = true
        
        Task {
            do {
                let tools = AgentToolRegistry.shared.allTools()
                var fullResponse = ""
                
                try await claudeService.streamMessage(
                    messages: conversation.messages.dropLast(),
                    tools: tools,
                    systemPrompt: conversation.systemPrompt,
                    onTextDelta: { [weak self] delta in
                        fullResponse += delta
                        if let lastMessage = conversation.messages.last {
                            lastMessage.contentBlocks = [.text(fullResponse)]
                        }
                        self?.objectWillChange.send()
                    },
                    onToolUse: { [weak self] block in
                        guard let toolName = block.name,
                              let input = block.input else { return }
                        
                        let toolCall = ToolCall(
                            toolName: toolName,
                            input: input,
                            status: .running
                        )
                        
                        if let lastMessage = conversation.messages.last {
                            lastMessage.toolCalls.append(toolCall)
                        }
                        self?.objectWillChange.send()
                        
                        // Execute tool
                        Task { @MainActor in
                            do {
                                let result = try await AgentToolRegistry.shared.execute(
                                    toolName: toolName,
                                    input: input
                                )
                                
                                // Update tool call status
                                if let lastMessage = conversation.messages.last,
                                   let index = lastMessage.toolCalls.firstIndex(where: { $0.id == toolCall.id }) {
                                    lastMessage.toolCalls[index].status = .completed
                                    lastMessage.toolCalls[index].result = result
                                    lastMessage.toolCalls[index].finishedAt = Date()
                                }
                                
                                // Add tool result to messages
                                let toolResultMessage = Message(
                                    role: .user,
                                    contentBlocks: [.toolResult(block.id ?? "", result)]
                                )
                                conversation.messages.append(toolResultMessage)
                                
                                self?.objectWillChange.send()
                            } catch {
                                if let lastMessage = conversation.messages.last,
                                   let index = lastMessage.toolCalls.firstIndex(where: { $0.id == toolCall.id }) {
                                    lastMessage.toolCalls[index].status = .failed
                                    lastMessage.toolCalls[index].result = error.localizedDescription
                                    lastMessage.toolCalls[index].finishedAt = Date()
                                }
                                self?.objectWillChange.send()
                            }
                        }
                    },
                    onComplete: { [weak self] response in
                        guard let lastMessage = conversation.messages.last else { return }
                        lastMessage.isStreaming = false
                        lastMessage.timestamp = Date()
                        
                        self?.isLoading = false
                        self?.saveConversations()
                        self?.objectWillChange.send()
                    },
                    onError: { [weak self] error in
                        self?.isLoading = false
                        self?.errorMessage = error.localizedDescription
                        
                        // Remove the empty assistant message on error
                        if let lastMessage = conversation.messages.last,
                           lastMessage.role == .assistant,
                           lastMessage.displayText.isEmpty {
                            conversation.messages.removeLast()
                        }
                        
                        self?.objectWillChange.send()
                    }
                )
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                objectWillChange.send()
            }
        }
    }
    
    func stopGenerating() {
        claudeService.cancelStream()
        isLoading = false
        
        if let lastMessage = currentConversation?.messages.last,
           lastMessage.role == .assistant {
            lastMessage.isStreaming = false
        }
        
        objectWillChange.send()
    }
    
    // MARK: - Persistence
    private func saveConversations() {
        persistenceService.saveConversations(conversations)
    }
    
    private func loadConversations() {
        conversations = persistenceService.loadConversations()
    }
    
    // MARK: - Tools
    func availableTools() -> [ClaudeToolDefinition] {
        AgentToolRegistry.shared.allTools()
    }
}

// MARK: - Tool Registry
class AgentToolRegistry {
    static let shared = AgentToolRegistry()
    
    private var tools: [String: AgentTool] = [:]
    
    private init() {
        registerDefaultTools()
    }
    
    func register(tool: AgentTool) {
        tools[tool.name] = tool
    }
    
    func allTools() -> [ClaudeToolDefinition] {
        tools.values.map { tool in
            try! ClaudeToolDefinition(
                name: tool.name,
                description: tool.description,
                inputSchema: tool.inputSchema
            )
        }
    }
    
    func execute(toolName: String, input: [String: JSONValue]) async throws -> String {
        guard let tool = tools[toolName] else {
            throw AgentToolError.toolNotFound(toolName)
        }
        return try await tool.execute(input: input)
    }
    
    private func registerDefaultTools() {
        register(tool: ReadFileTool())
        register(tool: WriteFileTool())
        register(tool: ListFilesTool())
        register(tool: WebSearchTool())
        register(tool: CalculatorTool())
        register(tool: DateTimeTool())
    }
}

// MARK: - Tool Protocol
protocol AgentTool {
    var name: String { get }
    var description: String { get }
    var inputSchema: [String: Any] { get }
    func execute(input: [String: JSONValue]) async throws -> String
}

enum AgentToolError: LocalizedError {
    case toolNotFound(String)
    case invalidInput(String)
    case executionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .toolNotFound(let name):
            return "Tool not found: \(name)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        }
    }
}

// MARK: - Default Tools
struct ReadFileTool: AgentTool {
    let name = "read_file"
    let description = "Read the contents of a file at the specified path"
    let inputSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "path": ["type": "string", "description": "The file path to read"]
        ],
        "required": ["path"]
    ]
    
    func execute(input: [String: JSONValue]) async throws -> String {
        guard let pathValue = input["path"],
              case .string(let path) = pathValue else {
            throw AgentToolError.invalidInput("Missing 'path' parameter")
        }
        
        if let content = try? String(contentsOfFile: path, encoding: .utf8) {
            return content
        } else {
            return "Error: Unable to read file at path: \(path)"
        }
    }
}

struct WriteFileTool: AgentTool {
    let name = "write_file"
    let description = "Write content to a file at the specified path"
    let inputSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "path": ["type": "string", "description": "The file path to write to"],
            "content": ["type": "string", "description": "The content to write"]
        ],
        "required": ["path", "content"]
    ]
    
    func execute(input: [String: JSONValue]) async throws -> String {
        guard let pathValue = input["path"],
              case .string(let path) = pathValue else {
            throw AgentToolError.invalidInput("Missing 'path' parameter")
        }
        
        guard let contentValue = input["content"],
              case .string(let content) = contentValue else {
            throw AgentToolError.invalidInput("Missing 'content' parameter")
        }
        
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        return "Successfully wrote \(content.count) characters to \(path)"
    }
}

struct ListFilesTool: AgentTool {
    let name = "list_files"
    let description = "List files in a directory"
    let inputSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "path": ["type": "string", "description": "The directory path to list"]
        ],
        "required": ["path"]
    ]
    
    func execute(input: [String: JSONValue]) async throws -> String {
        guard let pathValue = input["path"],
              case .string(let path) = pathValue else {
            throw AgentToolError.invalidInput("Missing 'path' parameter")
        }
        
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            return "Error: Unable to list directory at path: \(path)"
        }
        
        return contents.joined(separator: "\n")
    }
}

struct WebSearchTool: AgentTool {
    let name = "web_search"
    let description = "Search the web for information"
    let inputSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "query": ["type": "string", "description": "The search query"]
        ],
        "required": ["query"]
    ]
    
    func execute(input: [String: JSONValue]) async throws -> String {
        guard let queryValue = input["query"],
              case .string(let query) = queryValue else {
            throw AgentToolError.invalidInput("Missing 'query' parameter")
        }
        
        // Simulate web search result
        return "Web search results for '\(query)':\n1. Result 1: Information about \(query)\n2. Result 2: More details about \(query)\n3. Result 3: Additional resources for \(query)"
    }
}

struct CalculatorTool: AgentTool {
    let name = "calculator"
    let description = "Perform mathematical calculations"
    let inputSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "expression": ["type": "string", "description": "The mathematical expression to evaluate"]
        ],
        "required": ["expression"]
    ]
    
    func execute(input: [String: JSONValue]) async throws -> String {
        guard let exprValue = input["expression"],
              case .string(let expression) = exprValue else {
            throw AgentToolError.invalidInput("Missing 'expression' parameter")
        }
        
        // Note: Using NSExpression for safety (instead of eval)
        let expr = NSExpression(format: expression)
        if let result = expr.expressionValue(with: nil, context: nil) {
            return "Result: \(result)"
        } else {
            return "Error: Unable to evaluate expression"
        }
    }
}

struct DateTimeTool: AgentTool {
    let name = "datetime"
    let description = "Get current date and time information"
    let inputSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "format": ["type": "string", "description": "Optional format string (default: 'yyyy-MM-dd HH:mm:ss')"]
        ]
    ]
    
    func execute(input: [String: JSONValue]) async throws -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return "Current date and time: \(formatter.string(from: Date()))"
    }
}