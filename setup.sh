#!/bin/bash
# setup.sh - HermesAgent Project Setup Script

set -e

echo "========================================"
echo "  HermesAgent Project Setup"
echo "========================================"
echo ""

# Check for required tools
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is required but not installed."
        exit 1
    fi
    echo "✅ $1 found"
}

echo "Checking prerequisites..."
check_command git
check_command swift
echo ""

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "chore: initial project structure"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already initialized"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
*.xcworkspace/*
!*.xcworkspace/contents.xcworkspacedata
*.xcuserdata
*.xcuserstate
*.mode1v3
*.mode2v3

# Swift Package Manager
.build/
Packages/
Package.resolved

# CocoaPods
Pods/
*.podspec

# Carthage
Carthage/Build/

# Accio dependency management
Dependencies/
.accio/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Bundle
iOSInjectionProject/

# Code injection
*.swiftpm/xcode/

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Archives
*.zip
*.tar.gz
*.ipa

# Logs
*.log

# Build artifacts
DerivedData/
build/
*.o
*.linkfile
EOF
    echo "✅ .gitignore created"
fi

# Create Xcode project structure (placeholder)
if [ ! -f "HermesAgent.xcodeproj/project.pbxproj" ]; then
    echo ""
    echo "⚠️  Xcode project not found."
    echo "Please create the Xcode project manually:"
    echo "  1. Open Xcode"
    echo "  2. Create new iOS App project named 'HermesAgent'"
    echo "  3. Set interface to SwiftUI and language to Swift"
    echo "  4. Add existing files from HermesAgent/ folder"
    echo ""
fi

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Open Xcode and create the project"
echo "  2. Add your Anthropic API key in Settings"
echo "  3. Build and run on your iPad"
echo ""
echo "To run tests:"
echo "  swift test"
echo ""
echo "To build:"
echo "  swift build"
echo ""