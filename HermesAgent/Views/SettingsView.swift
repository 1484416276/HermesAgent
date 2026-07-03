// Views/SettingsView.swift
// HermesAgent - Settings View

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @StateObject private var claudeService = ClaudeService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAPIKeyAlert = false
    @State private var tempAPIKey = ""
    @State private var isTestingConnection = false
    @State private var connectionResult: String?
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            APISettingsView(
                isTestingConnection: $isTestingConnection,
                connectionResult: $connectionResult
            )
            .tabItem {
                Label("API", systemImage: "key.fill")
            }
            
            ModelSettingsView()
                .tabItem {
                    Label("Model", systemImage: "cpu")
                }
            
            DataSettingsView()
                .tabItem {
                    Label("Data", systemImage: "externaldrive")
                }
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Color Scheme", selection: $settingsStore.colorScheme) {
                    Text("System Default").tag(nil as ColorScheme?)
                    Text("Light").tag(ColorScheme.light as ColorScheme?)
                    Text("Dark").tag(ColorScheme.dark as ColorScheme?)
                }
                .pickerStyle(.radioGroup)
                
                HStack {
                    Text("Font Size")
                    Spacer()
                    Slider(value: $settingsStore.fontSize, in: 12...24, step: 1)
                    Text("\(Int(settingsStore.fontSize))pt")
                        .frame(width: 40)
                }
            }
            
            Section("Behavior") {
                Toggle("Stream Responses", isOn: $settingsStore.streamEnabled)
                Toggle("Sound Effects", isOn: $settingsStore.soundEnabled)
                Toggle("Haptic Feedback", isOn: $settingsStore.hapticEnabled)
            }
        }
        .padding()
        .navigationTitle("General Settings")
    }
}

// MARK: - API Settings
struct APISettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @StateObject private var claudeService = ClaudeService.shared
    @Binding var isTestingConnection: Bool
    @Binding var connectionResult: String?
    @Environment(\.dismiss) private var dismiss
    
    @State private var apiKey = ""
    @State private var baseURL = "https://api.anthropic.com"
    
    var body: some View {
        Form {
            Section("API Configuration") {
                SecureField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Base URL", text: $baseURL)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Test Connection") {
                        testConnection()
                    }
                    .disabled(apiKey.isEmpty || isTestingConnection)
                    
                    if isTestingConnection {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                if let result = connectionResult {
                    HStack {
                        Image(systemName: result.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(result.contains("Success") ? .green : .red)
                        Text(result)
                            .font(.caption)
                    }
                }
            }
            
            Section("Security") {
                Text("Your API key is stored securely in the system keychain and never leaves your device.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .navigationTitle("API Settings")
        .onAppear {
            apiKey = settingsStore.apiKey
            baseURL = claudeService.configuration.baseURL
        }
        .onChange(of: apiKey) { _, newValue in
            settingsStore.apiKey = newValue
            claudeService.configuration.apiKey = newValue
            claudeService.saveConfiguration()
        }
        .onChange(of: baseURL) { _, newValue in
            claudeService.configuration.baseURL = newValue
            claudeService.saveConfiguration()
        }
    }
    
    private func testConnection() {
        isTestingConnection = true
        connectionResult = nil
        
        Task {
            let success = await claudeService.testConnection()
            
            await MainActor.run {
                isTestingConnection = false
                connectionResult = success ? "✅ Connection successful!" : "❌ Connection failed. Check your API key."
            }
        }
    }
}

// MARK: - Model Settings
struct ModelSettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    
    var body: some View {
        Form {
            Section("Model Selection") {
                Picker("Model", selection: $settingsStore.model) {
                    ForEach(settingsStore.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            
            Section("Parameters") {
                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("4096", value: $settingsStore.maxTokens, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Temperature")
                    Spacer()
                    Slider(value: $settingsStore.temperature, in: 0...1, step: 0.1)
                    Text(String(format: "%.1f", settingsStore.temperature))
                        .frame(width: 40)
                }
            }
        }
        .padding()
        .navigationTitle("Model Settings")
    }
}

// MARK: - Data Settings
struct DataSettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @State private var showingClearAlert = false
    @State private var showingShareSheet = false
    @State private var exportData: Data?
    
    var body: some View {
        Form {
            Section("Export") {
                Button {
                    exportData = PersistenceService.shared.exportConversations()
                    if exportData != nil {
                        showingShareSheet = true
                    }
                } label: {
                    Label("Export Conversations", systemImage: "square.and.arrow.up")
                }
            }
            
            Section("Danger Zone") {
                Button(role: .destructive) {
                    showingClearAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                }
            }
        }
        .padding()
        .navigationTitle("Data Settings")
        .alert("Clear All Data?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all conversations and settings. This action cannot be undone.")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = exportData {
                ShareView(items: [data])
            }
        }
    }
    
    private func clearAllData() {
        PersistenceService.shared.clearAllData()
        chatViewModel.conversations.removeAll()
        chatViewModel.newConversation()
    }
}

// MARK: - Share View
struct ShareView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}