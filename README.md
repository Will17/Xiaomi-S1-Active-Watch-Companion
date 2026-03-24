# Xiaomi Watch S1 Active Companion App

A Flutter companion app for iOS that allows Xiaomi Watch S1 Active users to interact with ChatGPT and trigger automations using voice commands via Alexa.

## Features

### 🎤 Voice Command Integration via Alexa
- Receive voice commands from Xiaomi Watch S1 Active through Alexa routines
- Support for multiple intents (ChatGPT queries, text summarization, smart home commands)
- Webhook server for receiving Alexa JSON payloads
- Real-time command processing and response handling

### 🤖 ChatGPT Integration
- Full OpenAI ChatGPT API integration (gpt-4o-mini model)
- Multi-turn conversation memory
- Context-aware responses
- Text summarization capabilities
- Smart home command parsing

### ⌚ iOS Watch Notifications
- Optimized notifications for Xiaomi watch display
- Max 2-3 short lines with optional bullet points
- Interactive notification buttons (Summarize again, Next step, Execute, Cancel)
- Support for different notification categories

### 🏠 Automation System
- Timer and reminder management
- Smart home command processing
- Weather information retrieval
- Custom notifications
- Pending automation queue with execute/cancel options

### 🔒 Security & Privacy
- Secure API key storage using iOS Keychain
- Local conversation history storage
- Encrypted data storage
- Minimal cloud dependency

## Requirements

- iOS 16.0 or later
- Xiaomi Watch S1 Active with Alexa app
- OpenAI API key
- Flutter SDK (for development)

## Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd xiaomi_watch_companion
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate JSON Serialization Code
```bash
flutter packages pub run build_runner build
```

### 4. Build for iOS
```bash
flutter build ios
```

## Configuration

### 1. OpenAI API Key
1. Get your API key from [platform.openai.com](https://platform.openai.com)
2. Open the app and go to Settings → Configuration
3. Enter your API key (starts with "sk-")
4. Save the configuration

### 2. Alexa Webhook Setup

#### Option A: Local Webhook Server
1. In the app, go to Settings → Configuration
2. Enable "Local Webhook Server"
3. Note the webhook URL (e.g., `http://192.168.1.100:8080/webhook/alexa`)
4. Use this URL in your Alexa routine configuration

#### Option B: External Webhook Service
1. Set up a webhook service (ngrok, AWS API Gateway, etc.)
2. Enter the webhook URL in the app configuration
3. Configure your Alexa routine to use this URL

### 3. Alexa Routine Configuration

#### Creating a Voice Command Routine:
1. Open the Alexa app
2. Go to Routines → Create Routine
3. Set up voice trigger (e.g., "Hey Alexa, ask my watch")
4. Add "Custom" action
5. Select "Webhook" or "HTTP Request"
6. Configure the webhook:
   - URL: Your webhook URL from step 2
   - Method: POST
   - Headers: `Content-Type: application/json`
   - Body: See sample JSON below

## Sample Alexa Routine JSON

### Basic ChatGPT Query
```json
{
  "voice_input": "What's the weather like today?",
  "intent": "ChatGPTQuery",
  "user_id": "your_user_id",
  "device_id": "xiaomi_watch_s1_active",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Text Summarization
```json
{
  "voice_input": "Summarize this long article about artificial intelligence...",
  "intent": "SummarizeText",
  "user_id": "your_user_id",
  "device_id": "xiaomi_watch_s1_active",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Smart Home Command
```json
{
  "voice_input": "Turn on the living room lights",
  "intent": "SmartHomeCommand",
  "user_id": "your_user_id",
  "device_id": "xiaomi_watch_s1_active",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Timer Command
```json
{
  "voice_input": "Set a timer for 5 minutes",
  "intent": "SetTimer",
  "user_id": "your_user_id",
  "device_id": "xiaomi_watch_s1_active",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Reminder Command
```json
{
  "voice_input": "Remind me to call mom at 3 PM",
  "intent": "SetReminder",
  "user_id": "your_user_id",
  "device_id": "xiaomi_watch_s1_active",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## Supported Intents

| Intent | Description | Example |
|--------|-------------|---------|
| `ChatGPTQuery` | General ChatGPT conversation | "What's the capital of France?" |
| `SummarizeText` | Text summarization | "Summarize this article..." |
| `SmartHomeCommand` | Smart home control | "Turn on the lights" |
| `SetTimer` | Create timer | "Set timer for 10 minutes" |
| `SetReminder` | Create reminder | "Remind me to buy milk" |
| `GetWeather` | Weather information | "What's the weather?" |
| `SendNotification` | Custom notification | "Send notification to my phone" |

## Testing

### Test Webhook Endpoint
You can test the webhook using curl or any HTTP client:

```bash
curl -X POST http://localhost:8080/webhook/test \
  -H "Content-Type: application/json" \
  -d '{
    "voice_input": "Hello from test",
    "intent": "ChatGPTQuery",
    "user_id": "test_user",
    "device_id": "test_device"
  }'
```

### Test Notifications
Use the "Test Notification" button on the dashboard to verify watch notifications are working.

## Troubleshooting

### Common Issues

1. **Webhook Server Not Starting**
   - Check if port 8080 is available
   - Try a different port in configuration
   - Ensure iOS allows network access

2. **ChatGPT API Errors**
   - Verify API key is correct and active
   - Check OpenAI API quota and billing
   - Ensure network connectivity

3. **Notifications Not Showing**
   - Check iOS notification permissions
   - Verify watch is connected to iPhone
   - Check Do Not Disturb settings

4. **Alexa Routine Not Working**
   - Verify webhook URL is accessible
   - Check JSON payload format
   - Ensure routine is properly configured

## Development

### Project Structure
```
lib/
├── models/           # Data models (Alexa, ChatGPT, etc.)
├── services/         # Business logic (API, storage, notifications)
├── providers/        # State management
├── screens/          # UI screens
├── main.dart         # App entry point
```

### Key Dependencies
- `http` & `dio`: HTTP requests
- `flutter_secure_storage`: Secure key storage
- `flutter_local_notifications`: iOS notifications
- `shelf`: Webhook server
- `provider`: State management
- `google_fonts`: Typography

---

**Note**: This app requires an active OpenAI API subscription and may incur costs based on usage. Monitor your OpenAI API usage to avoid unexpected charges.
