// Views/SidebarView.swift
// HermesAgent - Sidebar View

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var settingsStore: SettingsStore
    @Binding var selectedConversationId: UUID?
    @Binding var showingSettings: Bool
    
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("HermesAgent")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("\(chatViewModel.conversations.count) conversations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    chatViewModel.newConversation()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                .buttonStyle(PlainButtonStyle())
                .help("New Conversation")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search conversations...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            
            // Conversation List
            List(selection: $selectedConversationId) {
                ForEach(filteredConversations) { conversation in
                    ConversationRow(conversation: conversation)
                        .tag(conversation.id)
                        .contextMenu {
                            Button("Delete") {
                                withAnimation {
                                    chatViewModel.deleteConversation(conversation)
                                }
                            }
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        chatViewModel.deleteConversation(filteredConversations[index])
                    }
                }
            }
            .listStyle(PlainListStyle())
            .searchable(text: $searchText, prompt: "Search conversations")
            
            // Footer
            HStack {
                ConnectionStatusView()
                Spacer()
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(PlainButtonStyle())
                .help("Settings")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 260, idealWidth: 300, maxWidth: 350)
    }
    
    private var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return chatViewModel.conversations
        } else {
            return chatViewModel.conversations.filter { conversation in
                conversation.title.localizedCaseInsensitiveContains(searchText) ||
                conversation.previewText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(conversation.previewText)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                Text(conversation.model)
                    .font(.caption2)
                    .foregroundColor(.tertiary)
                Spacer()
                Text(relativeTimeString(from: conversation.updatedAt))
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Connection Status
struct ConnectionStatusView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @StateObject private var claudeService = ClaudeService.shared
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(claudeService.isConnected ? .green : .red)
                .frame(width: 8, height: 8)
            
            Text(claudeService.isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
