QUICKSTART.md
=============

# HermesAgent Quick Start Guide

## 5-Minute Setup

### 1. Prerequisites Check
- [ ] iPad with iPadOS 17.0+
- [ ] Mac with Xcode 15.0+
- [ ] Anthropic API key from https://console.anthropic.com

### 2. Clone the Repository
```bash
git clone https://github.com/yourusername/HermesAgent.git
cd HermesAgent
```

### 3. Run Setup
```bash
chmod +x setup.sh
./setup.sh
```

### 4. Open in Xcode
```bash
open HermesAgent.xcodeproj
```

### 5. Configure API Key
1. Launch the app on your iPad (or simulator)
2. Tap the gear icon in the sidebar
3. Go to "API" tab
4. Paste your Anthropic API key
5. Tap "Test Connection"
6. ✅ You should see "Connection successful!"

### 6. Start Using!
Type your first message and experience HermesAgent!

---

## Common Issues

### "Cannot connect to API"
- Verify your API key is correct
- Check your internet connection
- Ensure you have API credits available

### "Build fails"
- Make sure you're using Xcode 15.0+
- Set deployment target to iOS 17.0
- Clean build folder (Cmd+Shift+K)

### "App crashes on launch"
- Check that all Swift files are added to the target
- Verify Info.plist is properly configured

---

## Development

```bash
# Run tests
swift test

# Build
swift build

# Format code (if you have swiftformat)
swiftformat .
```

---

## Need Help?

- Check the full [README.md](README.md)
- Open an [issue](https://github.com/yourusername/HermesAgent/issues)
- Read the [Architecture](#architecture) section

Happy coding! 🦋