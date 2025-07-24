# flutter_supabase_integration

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Features

### 🔐 Authentication
- Email/password sign up and sign in
- Magic link authentication
- Persistent login state with Shared Preferences
- Deep link handling for magic link authentication

### 📊 Dashboard
- Real-time message CRUD operations
- Message analytics with user statistics
- Modern UI with animations and skeleton loading
- Pull-to-refresh functionality

### 🔄 Real-time Updates
- **Supabase Realtime** integration for live message updates
- Automatic UI updates when messages are created, updated, or deleted
- Real-time connection status indicator
- No manual refresh needed - changes appear instantly

### 🧭 Navigation
- GoRouter for type-safe navigation
- Clean route management
- Deep link support

### 🎨 State Management
- Riverpod for reactive state management
- Freezed for immutable data models
- Clean architecture with separation of concerns

## Real-time Features

The app uses Supabase Realtime to provide live updates:

- **Live Status Indicator**: Shows connection status in the app bar
- **Instant Updates**: Messages appear/disappear/update in real-time
- **Automatic Sync**: No manual refresh needed
- **Error Handling**: Graceful handling of connection issues

### Testing Real-time

1. Open the app on multiple devices/browsers
2. Create, edit, or delete messages on one device
3. Watch the changes appear instantly on other devices
4. Use the WiFi icon in the app bar to test connection status
