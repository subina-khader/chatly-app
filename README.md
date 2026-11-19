# Chatly – AI Assistant & Personal Knowledge Workspace

A Flutter-based AI assistant and personal knowledge management application that combines AI conversations, note-taking, snippets, and learning cards in one place.

Chatly supports OpenAI and Google Gemini, allowing users to interact with AI through text, voice, and image inputs while organizing useful information into notes and snippets.

## Features

### 🤖 AI Chat
- Chat with AI using OpenAI or Google Gemini.
- Manage and revisit previous chat sessions.
- Start new conversations.
- Send voice input using speech recognition.
- Attach images from the gallery or camera.
- Use AI Smart Edit to fix grammar, rephrase, simplify, expand, shorten, or professionalize text.
- Save AI responses directly to notes or snippets.

### 📝 Workspace & Notes
- Create and organize notes into folders.
- Write and edit notes using a rich-text editor.
- Pin and unpin important notes.
- Search notes.
- Apply AI Smart Edit to selected text.
- Export individual notes or entire folders as PDF files.

### 📌 Snippets Vault
- Save useful information for quick access.
- Organize snippets by type: text, links, images, audio, numbers, and code.
- Edit, copy, filter, and delete snippets.
- Save AI-generated responses as snippets.

### 📚 Learning Cards
- Create custom learning cards.
- Set content refresh intervals (1, 2, 3, 7, 14, or 30 days).
- Refresh card content manually or when due.
- Save useful learning content.

### ⚙️ Settings & Guide
- Choose between OpenAI and Google Gemini.
- Configure API keys.
- Enable or disable Text-to-Speech.
- Configure automatic chat saving.
- Access an in-app guide for application usage.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Riverpod | State management |
| SQLite (sqflite) | Local database management |
| Shared Preferences | Local settings persistence |
| Path Provider | Local file and directory management |
| Flutter Quill | Rich-text editing |
| HTTP | API communication |
| Speech to Text | Voice input |
| Flutter TTS | Text-to-speech |
| Image Picker | Image selection |
| PDF | PDF generation |
| Printing | PDF preview and printing |
| Permission Handler | Runtime permission management |
| Share Plus | Sharing generated files |
| UUID | Unique identifier generation |

## Project Architecture

The application follows a modular architecture that separates UI components, state management, data models, and application services.

- **Screens & Widgets:** Handle the application interface and user interactions.
- **Providers:** Manage application state and business logic using Riverpod.
- **Models:** Represent messages, chat sessions, notes, folders, snippets, and learning cards.
- **Services:** Handle database operations, AI communication, PDF generation, speech recognition, media selection, and local storage.
- **Configuration:** Manage application settings and AI provider configuration.



## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (3.8.1 or compatible)
- Android Studio or Visual Studio Code
- OpenAI or Google Gemini API key

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/subina-khader/chatly-app.git
   ```

2. Navigate to the project directory:

   ```bash
   cd chatly-app
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

5. Open the application settings and configure your preferred AI provider and API key.

## Project Information

- **Project Name:** Chatly
- **Version:** 1.0.0+1
- **Framework:** Flutter
- **Language:** Dart

## Author

Developed as a personal Flutter project.
