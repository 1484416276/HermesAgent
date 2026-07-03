CHANGELOG.md
=============

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of HermesAgent
- Native iPad UI with split-view layout
- Claude API integration (Sonnet, Opus, Haiku)
- Real-time streaming responses
- Built-in agent tools:
  - `read_file` - Read file contents
  - `write_file` - Create/edit files
  - `list_files` - Browse directories
  - `web_search` - Search the web
  - `calculator` - Perform calculations
  - `datetime` - Get current date/time
- Multi-conversation management
- Local persistence with UserDefaults
- Export/import conversations
- Settings for model selection, temperature, max tokens
- Light/dark mode support
- Connection testing
- Error handling and user feedback
- Unit tests for models and services
- GitHub Actions CI/CD pipeline

### Security
- Secure API key storage
- HTTPS-only API communication
- No telemetry or data collection

### Documentation
- Comprehensive README.md
- Quick start guide
- MIT License
- Contributing guidelines

---

## [Unreleased]

### Planned
- Markdown rendering
- Code syntax highlighting
- Image generation support
- Voice input/output
- iCloud sync
- Custom tool plugins
- iPad keyboard shortcuts
- Multiple model providers (GPT-4, Gemini)
- Conversation branching
- Export to PDF/HTML