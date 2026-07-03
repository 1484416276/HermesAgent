// HermesAgentTests/ChatViewModelTests.swift
// HermesAgent - Chat ViewModel Tests

import XCTest
@testable import HermesAgent

final class ChatViewModelTests: XCTestCase {
    
    var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ChatViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testNewConversation() {
        viewModel.newConversation()
        
        XCTAssertEqual(viewModel.conversations.count, 1)
        XCTAssertNotNil(viewModel.currentConversation)
        XCTAssertEqual(viewModel.currentConversation?.title, "New Conversation")
        XCTAssertTrue(viewModel.currentConversation?.messages.isEmpty ?? false)
    }
    
    func testSelectConversation() {
        viewModel.newConversation()
        let firstId = viewModel.currentConversation!.id
        
        viewModel.newConversation()
        let secondId = viewModel.currentConversation!.id
        
        viewModel.selectConversation(id: firstId)
        XCTAssertEqual(viewModel.currentConversation?.id, firstId)
        
        viewModel.selectConversation(id: secondId)
        XCTAssertEqual(viewModel.currentConversation?.id, secondId)
    }
    
    func testDeleteConversation() {
        viewModel.newConversation()
        let conversationToDelete = viewModel.currentConversation!
        
        viewModel.newConversation()
        XCTAssertEqual(viewModel.conversations.count, 2)
        
        viewModel.deleteConversation(conversationToDelete)
        XCTAssertEqual(viewModel.conversations.count, 1)
        XCTAssertNil(viewModel.conversations.first(where: { $0.id == conversationToDelete.id }))
    }
    
    func testDeleteCurrentConversation() {
        viewModel.newConversation()
        let conversationToDelete = viewModel.currentConversation!
        
        viewModel.deleteConversation(conversationToDelete)
        XCTAssertNotNil(viewModel.currentConversation)
        XCTAssertNotEqual(viewModel.currentConversation?.id, conversationToDelete.id)
    }
    
    func testDeleteLastConversation() {
        viewModel.newConversation()
        let onlyConversation = viewModel.currentConversation!
        
        viewModel.deleteConversation(onlyConversation)
        XCTAssertEqual(viewModel.conversations.count, 1)
        XCTAssertNotNil(viewModel.currentConversation)
    }
    
    func testSendMessage() {
        viewModel.newConversation()
        
        viewModel.sendMessage("Hello, HermesAgent!")
        
        let conversation = viewModel.currentConversation!
        XCTAssertEqual(conversation.messages.count, 2) // User message + assistant placeholder
        
        if case .text(let text) = conversation.messages[0].contentBlocks.first {
            XCTAssertEqual(text, "Hello, HermesAgent!")
        } else {
            XCTFail("Expected text content block")
        }
        
        XCTAssertEqual(conversation.messages[1].role, .assistant)
    }
    
    func testAutoGenerateTitle() {
        viewModel.newConversation()
        
        viewModel.sendMessage("This is the first message that should become the title")
        
        let conversation = viewModel.currentConversation!
        XCTAssertEqual(conversation.title, "This is the first message that should become the title")
    }
    
    func testAvailableTools() {
        let tools = viewModel.availableTools()
        
        XCTAssertFalse(tools.isEmpty)
        XCTAssertTrue(tools.contains { $0.name == "read_file" })
        XCTAssertTrue(tools.contains { $0.name == "write_file" })
        XCTAssertTrue(tools.contains { $0.name == "calculator" })
        XCTAssertTrue(tools.contains { $0.name == "web_search" })
    }
}