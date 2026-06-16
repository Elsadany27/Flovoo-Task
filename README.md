# Flovoo Task

A Flutter messaging app that lets you sign in with an email, browse conversations, send messages and emojis, and receive simulated replies — all stored locally on the device.

---

## Table of Contents

- [Overview](#overview)
- [How to Use the App](#how-to-use-the-app)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture (MVVM)](#architecture-mvvm)
- [Project Structure](#project-structure)
- [Implementation Details](#implementation-details)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)

---

## Overview

**Flovoo** is a chat-style mobile application built with Flutter. It simulates a messaging experience without a backend server. User sessions, chat history, and theme preferences are persisted locally using **Hive**. When you send a message, the app updates the UI immediately (optimistic update), shows delivery status, and generates an automatic reply after a short delay.

Each user is identified by their email address. Chats and messages are scoped per email, so different accounts keep separate conversation data.

---

## How to Use the App

### 1. Sign In

1. Launch the app.
2. On the **Sign in** screen, enter a valid email address (e.g. `you@example.com`).
3. Tap **Continue**.
4. If the email is valid, you are taken to the **Messages** screen.
5. Your email is saved locally, so the next time you open the app you will skip login automatically.

### 2. Messages List

On the **Messages** screen you can:

- **View conversations** — See a list of chats sorted by most recent activity.
- **See unread counts** — Chats with unread messages show a badge.
- **Search** — Tap the search icon to filter conversations by contact name, last message preview, or message content.
- **Toggle theme** — Switch between light and dark mode using the sun/moon icon.
- **Switch account** — Tap the logout icon to sign out and return to the login screen.

When you open the app for the first time with a new email, two sample conversations (Sarah Johnson and James Miller) are created automatically.

### 3. Conversation

Tap any chat to open the conversation screen. Here you can:

- **Read messages** — Scroll through the full message history.
- **Send text** — Type in the input field and tap the send button (or press Enter).
- **Send emojis** — Tap a quick-reply emoji from the row above the text field to send it instantly.
- **Search messages** — Use the search icon in the app bar to filter messages in the current chat.
- **See typing indicator** — After you send a message, the contact appears as “typing…” for about 2 seconds before a simulated reply arrives.
- **Track message status** — Your sent messages show status progression: **sending → sent → delivered**.

When you go back to the messages list, unread counts are cleared for the chat you opened.

---

## Features

| Feature | Description |
|--------|-------------|
| Email-based login | Simple sign-in with email validation; session persisted locally |
| Persistent chats | All conversations saved on device with Hive |
| Default seed data | First-time users get two pre-populated sample chats |
| Real-time UI updates | Optimistic message sending with status updates |
| Simulated replies | Auto-generated responses based on message content |
| Typing indicator | Shows when the contact is “typing” before replying |
| Search | Filter chats and messages by text or emoji |
| Light / dark theme | Theme preference saved and restored across sessions |
| Per-user data | Chats are stored separately for each email account |

---

## Technology Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| Framework | **Flutter** | Cross-platform UI (Android, iOS, etc.) |
| Language | **Dart** (^3.10) | Application logic |
| Architecture pattern | **MVVM** | Separation of UI, state, and data |
| State management | **flutter_bloc** (Cubit) | ViewModels that expose state to the UI |
| Dependency injection | **get_it** | Service locator for shared services |
| Local storage | **Hive** + **hive_flutter** | NoSQL persistence for chats, session, and settings |
| Equality / state diff | **equatable** | Value equality for state classes |
| Date formatting | **intl** | Human-readable timestamps (Today, Yesterday, etc.) |
| UI | **Material Design 3** | Theming, components, and layout |

---

## Architecture (MVVM)

The app follows the **Model–View–ViewModel (MVVM)** pattern, adapted for Flutter using **Cubit** from the BLoC library as the ViewModel layer.

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEW                                │
│  Screens & Widgets                                          │
│  (LoginScreen, ChatsListScreen, ConversationScreen,         │
│   MessageBubble, MessageInput, ChatListItem, …)             │
│                                                             │
│  • Renders UI from ViewModel state                          │
│  • Dispatches user actions to ViewModel (Cubit)             │
│  • Uses BlocBuilder / BlocListener / BlocConsumer           │
└──────────────────────────┬──────────────────────────────────┘
                           │ observes state / calls methods
┌──────────────────────────▼──────────────────────────────────┐
│                      VIEWMODEL                              │
│  Cubits (LoginCubit, ChatsCubit, ConversationCubit)         │
│  + State classes (LoginState, ChatsState, ConversationState)│
│                                                             │
│  • Holds UI state and business logic                        │
│  • Talks to services/repositories                           │
│  • Emits new state when data changes                        │
└──────────────────────────┬──────────────────────────────────┘
                           │ reads / writes
┌──────────────────────────▼──────────────────────────────────┐
│                        MODEL                                │
│  Data models + Services                                     │
│  (ChatModel, MessageModel, ChatStorageService,              │
│   SessionService, HiveService, SimulatedReplyService)        │
│                                                             │
│  • Domain/data structures                                   │
│  • Persistence and side effects                             │
└─────────────────────────────────────────────────────────────┘
```

### View (Presentation Layer)

Located under `lib/features/*/view/`:

- **Screens** — Full-page widgets (`login_screen.dart`, `chats_list_screen.dart`, `conversation_screen.dart`).
- **Widgets** — Reusable UI pieces (`message_bubble.dart`, `message_input.dart`, `chat_list_item.dart`, `typing_indicator.dart`).

Views are kept thin: they display state from Cubits and forward user input (button taps, text changes) back to the ViewModel. Navigation side effects (e.g. go to chats after login) are handled in `BlocListener`.

### ViewModel (Cubit Layer)

Each feature has a Cubit that acts as the ViewModel:

| Cubit | Responsibility |
|-------|----------------|
| `LoginCubit` | Validates and saves email via `SessionService` |
| `ChatsCubit` | Loads chat list, handles search filter and logout |
| `ConversationCubit` | Loads a chat, sends messages, simulates replies and typing |

State is immutable and defined in separate classes (`LoginState`, `ChatsState`, `ConversationState`) using **Equatable** for efficient rebuilds. Computed properties like `filteredChats` and `visibleMessages` live on the state objects.

### Model (Data Layer)

Located under `lib/features/chats/data/` and `lib/core/services/`:

- **Models** — `ChatModel`, `MessageModel` with Hive type adapters for serialization.
- **Seed data** — `DefaultChats` provides initial conversations for new users.
- **Services** — Encapsulate storage and business rules:
  - `HiveService` — Initializes Hive and opens boxes.
  - `ChatStorageService` — CRUD for chats per email.
  - `SessionService` — Login session (current email).
  - `ThemeService` — Light/dark theme persistence.
  - `SimulatedReplyService` — Builds automatic replies.

### Dependency Injection

`get_it` registers singleton services in `service_locator.dart`. Cubits receive services via constructor injection (with `getIt` as fallback), which keeps ViewModels testable and decoupled from global state.

---

## Project Structure

```
lib/
├── main.dart                          # App entry, routing, theme setup
├── core/
│   ├── constants/
│   │   └── hive_constants.dart        # Hive box names and keys
│   ├── di/
│   │   └── service_locator.dart       # get_it registration
│   ├── routes/
│   │   └── app_routes.dart            # Route name constants
│   ├── services/
│   │   ├── chat_storage_service.dart  # Chat persistence
│   │   ├── hive_service.dart          # Hive initialization
│   │   ├── session_service.dart       # User session
│   │   ├── simulated_reply_service.dart
│   │   └── theme_service.dart         # Theme mode persistence
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart             # Light & dark Material themes
│   └── utils/
│       └── time_formatter.dart        # Relative time labels
└── features/
    ├── login/
    │   └── view/
    │       ├── cubit/                 # Login ViewModel
    │       │   ├── login_cubit.dart
    │       │   └── login_state.dart
    │       └── screens/
    │           └── login_screen.dart
    └── chats/
        ├── data/
        │   ├── models/                # Chat & message models
        │   └── seed/
        │       └── default_chats.dart
        └── view/
            ├── cubit/                 # Chats & conversation ViewModels
            ├── screens/
            └── widgets/
```

---

## Implementation Details

### Local Persistence (Hive)

- **`app_box`** — Stores the logged-in email and theme mode.
- **`chats_box`** — Stores chat lists keyed by email (`chats_<email>`).
- Custom **Hive adapters** serialize `ChatModel` and `MessageModel` to disk.
- On first launch for a new email, `ChatStorageService.ensureDefaultChats()` seeds two sample conversations.

### Message Sending Flow

1. User sends text or taps an emoji.
2. `ConversationCubit` adds the message to the UI immediately with status **sending** (optimistic update).
3. Message is persisted to Hive.
4. Status updates to **sent**, then **delivered** after a short delay.
5. Typing indicator is shown for ~2 seconds.
6. `SimulatedReplyService` generates a reply (e.g. “Hello 👋” for greetings, “Thanks for your message!” otherwise).
7. Reply is saved and displayed in the conversation.

### Search

- **Chats list** — Filters by contact name, last message preview, or any message text/emoji in the chat.
- **Conversation** — Filters visible messages by text or emoji content.
- Search query is held in Cubit state; filtering is done via getters on state classes (`filteredChats`, `visibleMessages`).

### Theme

`ThemeService` extends `ChangeNotifier` and persists the selected `ThemeMode` in Hive. The root `MaterialApp` uses `ListenableBuilder` to rebuild when the theme changes. Toggle is available from the chats list and conversation app bars.

### Session & Routing

- On startup, `main.dart` checks `SessionService.currentEmail`.
- If logged in → initial route is `/chats`; otherwise → `/` (login).
- Logout clears the stored email and navigates back to the login screen.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (compatible with Dart ^3.10)
- Android Studio / VS Code with Flutter extensions, or Xcode for iOS

### Install Dependencies

```bash
flutter pub get
```

---

## Running the App

```bash
# Run on a connected device or emulator
flutter run

# Run on a specific device
flutter devices
flutter run -d <device_id>
```

### Build APK (Android)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Summary

Flovoo is a locally persisted chat demo built with **Flutter** and **MVVM**. The **View** layer renders Material UI and reacts to Cubit state; **ViewModels** (Cubits) manage login, chat list, and conversation logic; the **Model** layer (Hive-backed services and data classes) handles persistence and simulated messaging. The result is a clean, feature-based structure that separates concerns and scales well for additional screens or a real backend later.


link Drive Apk :
https://drive.google.com/drive/folders/1l1oDLM2Uc_WlE0PpUCmafmHDaBmtamzv?usp=drive_link