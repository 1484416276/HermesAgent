CONTRIBUTING.md
===============

# Contributing to HermesAgent

Thanks for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Prioritize the project's and community's benefit

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/yourusername/HermesAgent/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Device/iPadOS version

### Suggesting Features

1. Search existing issues for similar suggestions
2. Create a new issue with:
   - Clear use case
   - Expected behavior
   - Why it would be useful

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/my-awesome-feature
   ```
3. **Make your changes**
   - Follow Swift API Design Guidelines
   - Write tests for new functionality
   - Update documentation as needed
4. **Run tests**
   ```bash
   swift test
   ```
5. **Commit with clear message**
   ```bash
   git commit -m "feat: add awesome feature"
   ```
6. **Push and create PR**
   ```bash
   git push origin feature/my-awesome-feature
   ```

## Development Setup

1. Clone your fork
2. Run `./setup.sh`
3. Open in Xcode
4. Create a new branch for your feature

## Style Guide

### Swift
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use trailing closures
- Prefer `let` over `var`

### Commits
Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Formatting, missing semicolons, etc.
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## Testing

All new features should include tests:

```swift
func testFeature() {
    // Arrange
    // Act
    // Assert
}
```

Run tests before submitting:
```bash
swift test
```

## Areas for Contribution

- [ ] UI/UX improvements
- [ ] Additional agent tools
- [ ] Performance optimizations
- [ ] Test coverage improvements
- [ ] Documentation
- [ ] Bug fixes
- [ ] Accessibility features
- [ ] Localization

## Questions?

Open an issue or reach out to the maintainers.

Thank you for contributing! 🦋