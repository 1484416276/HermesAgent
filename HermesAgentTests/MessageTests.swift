// HermesAgentTests/MessageTests.swift
// HermesAgent - Message Model Tests

import XCTest
@testable import HermesAgent

final class MessageTests: XCTestCase {
    
    func testMessageCreation() {
        let message = Message(
            role: .user,
            contentBlocks: [.text("Hello, world!")]
        )
        
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.textContent, "Hello, world!")
        XCTAssertFalse(message.isStreaming)
    }
    
    func testMessageDisplayTextWithStreaming() {
        var message = Message(
            role: .assistant,
            contentBlocks: [.text("Hello")],
            isStreaming: true
        )
        
        XCTAssertTrue(message.displayText.hasSuffix("▌"))
        XCTAssertEqual(message.displayText, "Hello ▌")
        
        message.isStreaming = false
        XCTAssertFalse(message.displayText.hasSuffix("▌"))
        XCTAssertEqual(message.displayText, "Hello")
    }
    
    func testContentBlockText() {
        let textBlock: ContentBlock = .text("Test text")
        let imageBlock: ContentBlock = .image(Data(), "image/png")
        let toolBlock: ContentBlock = .toolUse("calculator", ["expression": .string("1+1")])
        
        XCTAssertEqual(textBlock.text, "Test text")
        XCTAssertNil(imageBlock.text)
        XCTAssertNil(toolBlock.text)
    }
    
    func testConversationCreation() {
        let conversation = Conversation(
            title: "Test Conversation",
            messages: []
        )
        
        XCTAssertEqual(conversation.title, "Test Conversation")
        XCTAssertTrue(conversation.messages.isEmpty)
        XCTAssertNotNil(conversation.id)
    }
    
    func testConversationPreviewText() {
        let message = Message(role: .user, contentBlocks: [.text("This is a long message that should be truncated in the preview")])
        let conversation = Conversation(messages: [message])
        
        let preview = conversation.previewText
        XCTAssertTrue(preview.count <= 80)
    }
    
    func testToolCallStatus() {
        let pendingCall = ToolCall(toolName: "test", input: [:], status: .pending)
        let runningCall = ToolCall(toolName: "test", input: [:], status: .running)
        let completedCall = ToolCall(toolName: "test", input: [:], status: .completed)
        let failedCall = ToolCall(toolName: "test", input: [:], status: .failed)
        
        XCTAssertEqual(pendingCall.status.displayText, "⏳ Pending")
        XCTAssertEqual(runningCall.status.displayText, "🔄 Running")
        XCTAssertEqual(completedCall.status.displayText, "✅ Completed")
        XCTAssertEqual(failedCall.status.displayText, "❌ Failed")
    }
    
    func testJSONValueCodable() throws {
        let json: [String: JSONValue] = [
            "string": .string("hello"),
            "number": .number(42.5),
            "bool": .bool(true),
            "null": .null,
            "object": .object(["key": .string("value")]),
            "array": .array([.string("item1"), .number(123)])
        ]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(json)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([String: JSONValue].self, from: data)
        
        XCTAssertEqual(decoded["string"]?.string, "hello")
        XCTAssertEqual(decoded["number"]?.number, 42.5)
        XCTAssertEqual(decoded["bool"]?.bool, true)
        XCTAssertTrue(decoded["null"]?.isNull == true)
    }
}