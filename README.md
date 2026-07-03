# HermesAgent 🦋

<div align="center">

  <img src="https://img.shields.io/badge/iOS-17.0+-007AFF?style=for-the-badge" alt="iOS 17+"/>
  <img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge" alt="Swift 5.9+"/>
  <img src="="https://img.shields.io/badge/SwiftUI-Enabled-FF2D55?style=for-the-badge" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>

  <h1>HermesAgent</h1>
  <h3>A sophisticated iPad AI Agent application inspired by Claude Code</h3>

  [Features](#features) • [Screenshots](#screenshots) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture) • [Contributing](#contributing)

</div>

---

## Overview

**HermesAgent** is an elegant, powerful AI assistant interface designed exclusively for iPad. Built with SwiftUI and inspired by the sophisticated design philosophy of Hermès and the powerful capabilities of Claude Code, it provides a premium conversational AI experience with advanced agent capabilities.

## Features ✨

### 🎨 Premium iPad Design
- **Native iPad Layout**: Optimized split-view interface leveraging iPad's large screen real estate
- **Hermès-Inspired Aesthetics**: Elegant gradients, refined typography, and luxurious visual hierarchy
- **Adaptive Appearance**: Seamless light/dark mode support with custom color schemes
- **Fluid Animations**: Smooth transitions and micro-interactions throughout

### 🤖 Advanced AI Agent Capabilities
- **Claude API Integration**: Full support for Claude Sonnet, Opus, and Haiku models
- **Streaming Responses**: Real-time text streaming with typewriter effect
- **Tool Use (Function Calling)**: Execute code, search the web, read/write files, and more
- **Multi-Conversation Management**: Create, search, and organize multiple chat sessions
- **Persistent Storage**: All conversations saved locally with export/import support

### 🛠️ Built-in Agent Tools
| Tool | Description |
|------|-------------|
| `read_file` | Read contents of any file |
| `write_file` | Create and edit files |
| `list_files` | Browse directories |
| `web_search` | Search the web for information |
| `calculator` | Perform complex calculations |
| `datetime` | Get current date/time information |

### ⚙️ Comprehensive Settings
- **Model Selection**: Choose between Claude 3.5 Sonnet, Opus, or Haiku
- **Parameter Tuning**: Adjust max tokens, temperature, and top-p settings
- **API Configuration**: Secure API key management with connection testing
- **Data Management**: Export conversations, clear data, import backups
- **Appearance**: Customize font size, color scheme, and behavior

### 🔒 Privacy & Security
- **Local Storage**: All data stored securely on your device
- **No Telemetry**: Zero data collection or tracking
- **Secure API**: Direct HTTPS connection to Anthropic's API
- **Keychain Storage**: API keys stored in system keychain (in production)

## Screenshots 📱

<div align="center">

| Welcome Screen | Chat Interface | Settings |
|:---:|:---:|:---:|
| <img src="https://via.placeholder.com/300x200/FF6B35/FFFFFF?text=Welcome" width="200"/> | <img src="https://via.placeholder.com/300x200/7B2D8E/FFFFFF?text=Chat" width="200"/> | <img src="https://via.placeholder.com/300x200/2D8E7B/FFFFFF?text=Settings" width="200"/> |

</div>

## Installation 🚀

### Prerequisites
- iPadOS 17.0 or later
- Xcode 15.0 or later
- Anthropic API key (get one at [console.anthropic.com](https://console.anthropic.com))
- Swift 5.9+

### From Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/HermesAgent.git
   cd HermesAgent
   ```

2. **Open in Xcode**
   ```bash
   open HermesAgent.xcodeproj
   ```

3. **Configure API Key**
   - Launch the app
   - Go to Settings → API
   - Enter your Anthropic API key
   - Test the connection

4. **Build and Run**
   - Select your iPad as the target
   - Press Cmd+R to build and run

### Using Swift Package Manager

```bash
swift build
swift test
```

## Usage 📖

### Getting Started

1. **Launch HermesAgent** on your iPad
2. **Configure API Key** in Settings if not done
3. **Start Chatting**: Type your message and press send
4. **Use Tools**: Ask the agent to perform tasks like:
   - "Read the file at /path/to/file.txt"
   - "Calculate 15% of 2847"
   - "What's the current date and time?"
   - "Search the web for SwiftUI tutorials"

### Conversation Management

- **New Conversation**: Click the compose button in the sidebar
- **Search**: Use the search bar to find past conversations
- **Delete**: Swipe left on any conversation to delete
- **Export**: Go to Settings → Data → Export Conversations

### Tool Usage

The agent can automatically use tools when needed:

```swift
// Example conversation
User: "Read the README.md file and summarize it"
Assistant: [Uses read_file tool] "The README describes..."

User: "Calculate the square root of 144"
Assistant: [Uses calculator tool] "The result is 12.0"
```

## Architecture 🏗️

```
HermesAgent/
├── HermesAgentApp.swift           # App entry point & main layout
├── Models/
│   ├── Message.swift              # Core data models
│   └── Conversation.swift
├── Services/
│   ├── ClaudeService.swift        # Claude API integration
│   ├── PersistenceService.swift   # Local storage
│   └── SettingsStore.swift        # App settings
├── ViewModels/
│   └── ChatViewModel.swift        # Business logic & tool registry
├── Views/
│   ├── SidebarView.swift          # Conversation list
│   ├── ChatView.swift             # Message interface
│   └── SettingsView.swift         # Configuration screens
└── HermesAgentTests/              # Unit tests
```

### Key Components

- **MVVM Architecture**: Clean separation of concerns
- **ObservableObject**: Reactive state management
- **SwiftUI**: Declarative UI framework
- **Async/Await**: Modern concurrency for API calls
- **Streaming**: Real-time response handling

## Testing 🧪

Run the test suite:

```bash
# Using Swift Package Manager
swift test

# Using Xcode
# Product → Test (Cmd+U)
```

### Test Coverage
- Model unit tests
- Service integration tests
- ViewModel logic tests
- Tool execution tests

## Contributing 🤝

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Development Guidelines
- Follow Swift API Design Guidelines
- Write tests for new features
- Update documentation as needed
- Ensure iPad compatibility

## Roadmap 🗺️

- [ ] Code syntax highlighting
- [ ] Markdown rendering
- [ ] Image generation support (DALL-E/Stable Diffusion)
- [ ] Voice input/output
- [ ] iCloud sync
- [ ] Custom tool plugins
- [ ] iPad keyboard shortcuts
- [ ] Multiple model support (GPT-4, Gemini)
- [ ] Conversation branching
- [ ] Export to PDF/HTML

## Acknowledgments 🙏

- [Anthropic](https://www.anthropic.com) for the Claude API
- Inspired by [Claude Code](https://claude.ai/code) and [Hermès](https://www.hermes.com)
- Built with [SwiftUI](https://developer.apple.com/swiftui/)

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

- 📧 Email: your.email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/HermesAgent/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/HermesAgent/discussions)

---

<div align="center">

Made with ❤️ for iPad users everywhere

[⬆ Back to top](#hermesagent-)

</div>