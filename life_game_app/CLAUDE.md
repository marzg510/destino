# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter Flame game project called "Life Game" that demonstrates a simple bouncing square animation. The project is built using Flutter 3.32.6 with Dart 3.8.1 and uses the Flame game engine for game development.

## Architecture

### Core Components

- **main.dart**: Entry point that creates a Flutter MaterialApp with a GameWidget hosting the LifeGame
- **game.dart**: Contains the main game logic with two key classes:
  - `LifeGame`: Main game class extending FlameGame with collision detection
  - `MovingSquare`: A RectangleComponent that moves around the screen and bounces off walls

### Game Structure

The game follows Flame's component-based architecture:
- `LifeGame` serves as the main game controller
- Components like `MovingSquare` are added to the game and handle their own update logic
- Uses `HasGameReference` mixin for components to access the parent game instance
- Implements basic collision detection with screen boundaries

## Development Commands

### Running the Application
```bash
flutter run
```

### Testing
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Dependencies Management
```bash
flutter pub get          # Install dependencies
flutter pub upgrade      # Update dependencies
```

### Building
```bash
flutter build web        # Build for web
flutter build apk        # Build Android APK (requires Android SDK)
flutter build ios        # Build for iOS (requires macOS and Xcode)
```

## Key Dependencies

- **flame**: ^1.18.0 - Main game engine
- **flame_audio**: ^2.1.2 - Audio support for games
- **flutter_lints**: ^6.0.0 - Dart linting rules

## Development Environment

- The project uses `flutter_lints` for code quality enforcement
- Analysis options are configured in `analysis_options.yaml`
- The project includes platform-specific configurations for Android, iOS, Web, Linux, macOS, and Windows

## Testing

- Widget tests are located in `test/widget_test.dart`
- Current test is a placeholder counter test that needs to be updated for the actual game functionality
- Use `flutter test` to run all tests

## Game Development Patterns

When working with Flame components:
- Extend appropriate base classes (e.g., `RectangleComponent`, `SpriteComponent`)
- Use mixins like `HasGameReference` to access game instance
- Implement `onLoad()` for initialization
- Use `update(double dt)` for frame-based updates
- Handle collision detection through `HasCollisionDetection` mixin on the game class

## Project Structure

- `lib/`: Main source code
- `test/`: Test files
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`: Platform-specific configurations
- `pubspec.yaml`: Dependencies and project configuration