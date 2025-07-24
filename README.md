# Flutter Supabase Integration

A comprehensive Flutter application demonstrating integration with Supabase backend services, featuring real-time messaging, authentication, and analytics.

## Features

### 🔐 Authentication
- Email/password sign up and sign in
- Magic link authentication
- Persistent login state with Shared Preferences
- Secure logout functionality

### 💬 Real-time Messaging
- **Live message updates** using Supabase Realtime
- Create, read, update, and delete (CRUD) operations
- Real-time synchronization across all connected clients
- Message history with user attribution

### 📊 Analytics Dashboard
- Real-time message statistics
- User activity tracking
- Message count per user
- Visual analytics with charts

### 🎨 Modern UI/UX
- Clean, modern design with animations
- Skeleton loading states
- Pull-to-refresh functionality
- Responsive layout
- Dark/light theme support

### 🧭 Navigation
- GoRouter for type-safe navigation
- Deep linking support
- Magic link redirect handling

### 📱 State Management
- Riverpod for reactive state management
- Freezed for immutable data models
- Clean architecture principles

## Real-time Features

The app includes **Supabase Realtime** integration for live updates:

- **Live Status Indicator**: Shows connection status in the app bar
- **Automatic Updates**: Messages update in real-time across all devices
- **Connection Management**: Automatic subscription handling
- **Error Handling**: Graceful fallback for connection issues

### How Real-time Works

1. **Subscription**: App subscribes to `messages` table changes
2. **Live Updates**: Any CRUD operation triggers real-time updates
3. **UI Sync**: All connected clients see changes instantly
4. **Connection Status**: Visual indicator shows live/offline status

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- FVM (Flutter Version Manager)
- Supabase account and project

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/herisarwanto/flutter-supabase-integration.git
   cd flutter-supabase-integration
   ```

2. **Install dependencies**
   ```bash
   fvm flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project
   - Set up authentication
   - Create the `messages` table
   - Enable Row Level Security (RLS)
   - Configure realtime for the `messages` table

4. **Update configuration**
   - Edit `lib/common/config/app_config.dart`
   - Add your Supabase URL and anon key

5. **Run the app**
   ```bash
   fvm flutter run
   ```

## Project Structure

```
lib/
├── common/
│   ├── config/          # App configuration
│   ├── router/          # Navigation setup
│   ├── services/        # Shared services
│   ├── theme/           # App theming
│   └── utils/           # Utility classes
├── features/
│   ├── auth/            # Authentication feature
│   ├── dashboard/       # Dashboard feature
│   └── intro/           # Intro screen
└── main.dart           # App entry point
```

## Technologies Used

- **Flutter**: UI framework
- **Supabase**: Backend as a Service
- **Riverpod**: State management
- **GoRouter**: Navigation
- **Freezed**: Code generation
- **FVM**: Flutter version management

## License

This project is licensed under the MIT License.
