<div align="center">
<img src="github/assets/sparkle.png" width="100" height="100">

# Sparkle

A native iOS app for chatting with Azure OpenAI's GPT models. Built with SwiftUI / SwiftData and featuring real-time streaming responses with Markdown support.

</div>

> [!NOTE]
> This project is a learning resource for me for working with SwiftUI, Azure OpenAI, and real-time streaming. While functional, it's intended as an educational example rather than a production-ready application.

## OTA Installation (Unsigned)

The App is available unsigned as an IPA on [diawi](https://i.diawi.com/AkE4D7). If you have a paid developer account, you might be able to sign it.

## Prerequisites

- iOS 18.2+
- Xcode 15.0 or later
- Azure OpenAI Service account with API access

## Getting Started

1. Clone this repository
2. Open `Sparkle.xcodeproj` in Xcode
3. Wait for Swift Package Manager to fetch dependencies
4. Configure your Azure OpenAI settings:
   - Base Endpoint (e.g., `https://your-resource.openai.azure.com`)
   - Deployment Name
   - API Key
5. Build and run (⌘ + R)

## Project Structure

### Core Components

- **ContentView**: Main chat interface with message bubbles and streaming responses
- **SettingsView**: Configuration view for Azure OpenAI settings

- **AzureOpenAIService**: Handles API communication with streaming support

### Features

#### Chat Interface

- Real-time message streaming
- Markdown rendering support
- Code block syntax highlighting
- Message bubbles with user/assistant avatars
- Auto-scrolling to latest messages
- Dark mode support

#### Settings

- Azure OpenAI configuration
- Persistent settings storage
- URL validation and preview
- Secure API key storage

#### Markdown Support

- Paragraphs
- Code blocks with language detection
- Headings
- Lists
- Text selection

### Dependencies

- [Swift Markdown](https://github.com/apple/swift-markdown) - For Markdown parsing and rendering

## Configuration

### Azure OpenAI Setup

1. Open Sparkle
2. Go to Settings (gear icon)
3. Enter your Azure OpenAI credentials:
   - Base Endpoint URL
   - Deployment Name
   - API Key

Settings are automatically saved and persisted between app launches.

## Development Notes

- Built using SwiftUI for modern, declarative UI
- Uses `@StateObject` and `ObservableObject` for state management
- Implements async/await for API communication
- Features real-time streaming using URLSession
- Supports universal deployment (iOS, iPadOS, macOS)

## Troubleshooting

### API Connection Issues

1. Verify Azure OpenAI credentials
2. Check endpoint URL format
3. Ensure deployment is active
4. Verify API key permissions

### Build Issues

1. Clean build folder (⇧ + ⌘ + K)
2. Update Swift packages
3. Verify Xcode version (15.0+)

## Platform Support

- iOS 18.2+
- iPadOS 18.2+ (Works barely)
- macOS 14.0+ (Works, but is not looking great)

## Security

- API keys are stored in UserDefaults
