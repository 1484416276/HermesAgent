// HermesAgentTests/ClaudeServiceTests.swift
// HermesAgent - Claude Service Tests

import XCTest
@testable import HermesAgent

final class ClaudeServiceTests: XCTestCase {
    
    var service: ClaudeService!
    
    override func setUp() {
        super.setUp()
        service = ClaudeService.shared
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testConfigurationInitialization() {
        XCTAssertNotNil(service.configuration)
        XCTAssertEqual(service.configuration.baseURL, "https://api.anthropic.com")
        XCTAssertEqual(service.configuration.model, "claude-sonnet-4-5-20250929")
        XCTAssertEqual(service.configuration.maxTokens, 4096)
        XCTAssertEqual(service.configuration.temperature, 1.0)
    }
    
    func testConfigurationPersistence() {
        let originalKey = service.configuration.apiKey
        service.configuration.apiKey = "test-api-key-12345"
        service.saveConfiguration()
        
        service.loadConfiguration()
        XCTAssertEqual(service.configuration.apiKey, "test-api-key-12345")
        
        // Restore
        service.configuration.apiKey = originalKey
        service.saveConfiguration()
    }
    
    func testHeadersGeneration() {
        let headers = service.configuration.headers
        
        XCTAssertNotNil(headers["x-api-key"])
        XCTAssertEqual(headers["anthropic-version"], "2023-06-01")
        XCTAssertEqual(headers["content-type"], "application/json")
    }
    
    func testSendMessageWithoutAPIKey() async throws {
        service.configuration.apiKey = ""
        
        do {
            let message = Message(role: .user, contentBlocks: [.text("Test")])
            _ = try await service.sendMessage(messages: [message])
            XCTFail("Expected error due to missing API key")
        } catch {
            // Expected
            XCTAssertTrue(true)
        }
    }
    
    func testStreamMessageCancellation() {
        let expectation = XCTestExpectation(description: "Stream cancellation")
        
        service.streamMessage(
            messages: [],
            onTextDelta: { _ in },
            onToolUse: { _ in },
            onComplete: { _ in
                XCTFail("Should not complete")
            },
            onError: { error in
                XCTAssertTrue(error is CancellationError)
                expectation.fulfill()
            }
        )
        
        // Cancel immediately
        service.cancelStream()
        
        wait(for: [expectation], timeout: 5.0)
    }
}