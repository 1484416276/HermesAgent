// Views/ChatView.swift
// HermesAgent - Chat View

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var settingsStore: SettingsStore
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @State private var showStopButton = false
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(conversation.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onChange(of: conversation.messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                
                // Input Area
                VStack(spacing: 12) {
                    if let error = chatViewModel.errorMessage {
                        ErrorBanner(message: error)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    HStack(alignment: .bottom, spacing: 12) {
                        TextField("Message HermesAgent...", text: $inputText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: settingsStore.fontSize))
                            .lineLimit(5...10)
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        if chatViewModel.isLoading {
                            Button {
                                chatViewModel.stopGenerating()
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Stop generating")
                        } else {
                            Button {
                                sendMessage()
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title)
                                    .foregroundColor(inputText.isEmpty ? .gray : .orange)
                                    .symbolEffect(.bounce, value: inputText.isEmpty == false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(inputText.isEmpty)
                            .help("Send message")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                    )
                }
            }
            .background(Color(NSColor.textBackgroundColor))
            .onAppear {
                scrollToBottom(proxy: proxy)
                isInputFocused = true
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        chatViewModel.sendMessage(text)
        inputText = ""
        isInputFocused = true
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = conversation.messages.last else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                // Role indicator
                if message.role == .assistant {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("HermesAgent")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                
                // Content
                if message.role == .assistant && !message.toolCalls.isEmpty {
                    // Tool calls view
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(message.toolCalls) { toolCall in
                            ToolCallBubble(toolCall: toolCall)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                    )
                }
                
                // Text content
                if !message.textContent.isEmpty {
                    Text(message.displayText)
                        .font(.system(size: settingsStore.fontSize))
                        .foregroundColor(message.role == .user ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(message.role == .user ? 
                                      LinearGradient(colors: [.orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                      Color(NSColor.controlBackgroundColor))
                        )
                }
                
                // Timestamp
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
            .frame(maxWidth: message.role == .user ? .infinity * 0.7 : .infinity * 0.85, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Tool Call Bubble
struct ToolCallBubble: View {
    let toolCall: ToolCall
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: toolCall.status == .completed ? "checkmark.circle.fill" :
                            toolCall.status == .running ? "arrow.triangle.2.circlepath" :
                            toolCall.status == .failed ? "xmark.circle.fill" : "circle")
                    .foregroundColor(statusColor)
                
                Text(toolCall.toolName)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(toolCall.status.displayText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let result = toolCall.result, toolCall.status == .completed || toolCall.status == .failed {
                Text(result)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var statusColor: Color {
        switch toolCall.status {
        case .completed: return .green
        case .running: return .orange
        case .failed: return .red
        case .pending: return .gray
        }
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}