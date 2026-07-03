// HermesAgentApp.swift
// HermesAgent - iPad AI Agent Application
// A sophisticated AI assistant interface inspired by Claude Code

import SwiftUI

@main
struct HermesAgentApp: App {
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var settingsStore = SettingsStore.shared
    
    var body: some Scene {
        WindowGroup {
            MainSplitView()
                .environmentObject(chatViewModel)
                .environmentObject(settingsStore)
                .preferredColorScheme(settingsStore.colorScheme)
                .onAppear {
                    setupAppearance()
                }
        }
        .commands {
            SidebarCommands()
            WindowCommands()
        }
    }
    
    private func setupAppearance() {
        // iPad optimized appearance
        UITableView.appearance().backgroundColor = .clear
        UINavigationBar.appearance().compactAppearance = UINavigationBarAppearance()
    }
}

// MARK: - Main Split View (iPad Layout)
struct MainSplitView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @State private var showingSettings = false
    @State private var selectedConversationId: UUID?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - Conversation List
            SidebarView(
                selectedConversationId: $selectedConversationId,
                showingSettings: $showingSettings
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 320)
        } detail: {
            // Main Content - Chat View
            if let conversation = chatViewModel.currentConversation {
                ChatView(conversation: conversation)
                    .navigationTitle(conversation.title)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                chatViewModel.newConversation()
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .help("New Conversation")
                        }
                    }
            } else {
                WelcomeView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settingsStore)
        }
        .onChange(of: selectedConversationId) { _, newId in
            if let id = newId {
                chatViewModel.selectConversation(id: id)
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    
    let suggestions: [String] = [
        "Explain quantum computing in simple terms",
        "Write a Swift function to sort an array",
        "Help me design a REST API",
        "Analyze the pros and cons of microservices"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo / Branding
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, 8)
            
            Text("HermesAgent")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Your intelligent iPad assistant")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Divider()
                .frame(width: 200)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Try asking:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        // Would send this as a message
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            Text(suggestion)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: 480)
            
            Spacer()
            
            Text("Powered by Claude Sonnet · Optimized for iPad")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Preview
struct HermesAgentApp_Previews: PreviewProvider {
    static var previews: some View {
        MainSplitView()
            .environmentObject(ChatViewModel())
            .environmentObject(SettingsStore.shared)
    }
}
