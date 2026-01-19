## Project Overview

**MobTimer** is a macOS menu bar application for managing mob programming/pair programming sessions. It tracks driver rotation, participant management, break schedules, and provides audio/visual notifications for rotation changes.

- **Minimum Deployment**: macOS 26.0 (Tahoe)
- **Swift Version**: 6.0 (Swift 6 language mode enabled)
- **Xcode**: 26.x
- **Architecture**: Apple Silicon primary, Intel x86_64 support
- **UI Framework**: SwiftUI with AppKit interop for system sounds
- **App Type**: Menu bar application (MenuBarExtra)

---

## Features

### Timer & Rotation
- Configurable rotation duration (1-30 minutes, or seconds in testing mode)
- Timer states: `stopped`, `running`, `paused`, `onBreak`, `awaitingDriver`
- Circular progress indicator with color-coded states
- Skip functionality and pause/resume support

### Participant Management
- Add/remove/edit participants
- Mark participants as "away" (excluded from rotation)
- Drag-and-drop reordering
- Away participants shown in separate FlowLayout section

### Notifications
- System notifications with optional sound on rotation
- Text-to-speech announcements with customizable templates
- Floating rotation window for driver acknowledgment
- Break notifications

### Persistence
- Automatic save/load of participants and settings
- Stored in `~/Library/Application Support/MobTimer/`

---

## Build System — XcodeBuildMCP

This project uses **XcodeBuildMCP** for AI-assisted build automation.

### Available Tools

```
# Project Discovery
discover_projs          # Find .xcworkspace/.xcodeproj in working directory
list_schemes            # List available schemes
show_build_settings     # Display build configuration

# Build Operations
build_macos             # Build for macOS target
clean_proj              # Clean build products

# App Lifecycle
launch_macos_app        # Launch built .app bundle
get_macos_bundle_id     # Extract bundle identifier
```

### Build Commands (via XcodeBuildMCP)

```bash
# Discover project first
discover_projs

# Build release
build_macos --scheme "MobTimer" --configuration Release

# Build debug
build_macos --scheme "MobTimer" --configuration Debug

# Clean before build
clean_proj --scheme "MobTimer"
```

---

## Project Structure

```
MobTimer/
├── MobTimer.xcodeproj/
├── MobTimer.xcworkspace/
├── MobTimer.entitlements           # App Sandbox only
├── Sources/
│   ├── App/
│   │   └── MobTimerApp.swift       # @main entry point, MenuBarExtra scene
│   ├── Core/
│   │   └── Services/
│   │       ├── PersistenceService.swift   # JSON file storage (actor)
│   │       ├── NotificationService.swift  # System notifications (actor)
│   │       └── SpeechService.swift        # Text-to-speech (actor)
│   ├── Features/
│   │   └── Timer/
│   │       ├── Models/
│   │       │   ├── Participant.swift      # Participant model
│   │       │   ├── TimerState.swift       # Timer state enum
│   │       │   └── TimerSettings.swift    # Settings model
│   │       ├── ViewModels/
│   │       │   └── TimerViewModel.swift   # Main view model
│   │       └── Views/
│   │           ├── TimerMenuView.swift        # Menu bar view container
│   │           ├── CircularProgressView.swift # Progress indicator
│   │           ├── RotationWindowView.swift   # Floating rotation alert
│   │           ├── ParticipantListView.swift  # Participant management
│   │           ├── ParticipantRowView.swift   # Individual row
│   │           ├── TimerControlsView.swift    # State-dependent controls
│   │           └── SettingsView.swift         # Settings modal
│   └── UI/
│       └── Components/
│           └── FlowLayout.swift       # Custom Layout for away participants
└── Resources/
    └── Assets.xcassets/
```

---

## Domain Models

### Participant
```swift
struct Participant: Identifiable, Codable, Sendable, Equatable, Hashable, Transferable {
    let id: UUID
    var name: String
    var isAway: Bool = false
}
```
- Conforms to `Transferable` for drag-drop (UTType: `com.mobtimer.participant`)

### TimerState
```swift
enum TimerState: Sendable, Equatable {
    case stopped
    case running
    case paused
    case onBreak
    case awaitingDriver
}
```

### TimerSettings
```swift
struct TimerSettings: Codable, Sendable, Equatable {
    var rotationDurationMinutes: Int = 5
    var rotationDurationSeconds: Int?  // Testing mode only
    var breakAfterRotations: Int?
    var breakDurationMinutes: Int = 10
    var playSoundOnRotation: Bool = true
    var speakAnnouncement: Bool = true
    var announcementTemplate: String = "Time's up! {name} is now driving."
}
```

---

## Architecture Patterns

### ViewModel Pattern
Single `@MainActor @Observable` ViewModel owned by the App:

```swift
@main
struct MobTimerApp: App {
    @State private var viewModel = TimerViewModel()

    var body: some Scene {
        MenuBarExtra {
            TimerMenuView(viewModel: viewModel)
        } label: {
            Text(viewModel.statusText)
        }

        Window("Rotation", id: "rotation") {
            RotationWindowView(viewModel: viewModel)
        }
    }
}
```

### View Binding
All views receive the ViewModel via `@Bindable`:

```swift
struct TimerMenuView: View {
    @Bindable var viewModel: TimerViewModel

    var body: some View {
        // ...
    }
}
```

### Actor-based Services
All services are actors with static `shared` instances:

```swift
actor PersistenceService {
    static let shared = PersistenceService()

    func saveParticipants(_ participants: [Participant]) async throws { ... }
    func loadParticipants() async throws -> [Participant] { ... }
}
```

---

## Swift 6 Concurrency

### Strict Concurrency Mode
Build settings:
```
SWIFT_VERSION = 6.0
SWIFT_STRICT_CONCURRENCY = complete
```

### Patterns Used

**@MainActor for UI-bound Types:**
```swift
@MainActor
@Observable
final class TimerViewModel {
    var participants: [Participant] = []
    var state: TimerState = .stopped
    // ...
}
```

**Sendable Models:**
```swift
struct Participant: Sendable { ... }
struct TimerSettings: Sendable { ... }
enum TimerState: Sendable { ... }
```

**Actor for Services:**
```swift
actor NotificationService {
    func sendRotationNotification(driverName: String) async { ... }
}
```

---

## Testing Mode

Launch with `--testing` or `-testing` flag to enable:
- Seconds-based rotation (5-60 seconds instead of minutes)
- Faster iteration for testing rotation behavior

```swift
private let isTestingMode = CommandLine.arguments.contains("--testing")
    || CommandLine.arguments.contains("-testing")
```

---

## Entitlements

Minimal sandboxing (no network, keychain, or file access beyond container):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
</dict>
</plist>
```

---

## Dependencies

**No external SPM dependencies** — uses only system frameworks:
- `SwiftUI` — UI
- `Foundation` — Core types, JSON, FileManager
- `AVFoundation` — Text-to-speech (`AVSpeechSynthesizer`)
- `UserNotifications` — System notifications
- `AppKit` — System sound (`NSSound.beep()`), app termination
- `UniformTypeIdentifiers` — Custom UTType for drag-drop

---

## Code Style

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| ViewModels | PascalCase + `ViewModel` | `TimerViewModel` |
| Views | PascalCase + `View` | `TimerMenuView` |
| Models | PascalCase | `Participant`, `TimerSettings` |
| Enums | PascalCase | `TimerState` |
| Services | PascalCase + `Service` | `PersistenceService` |
| Properties | lowerCamelCase | `currentDriver`, `remainingSeconds` |

### File Organization
- Each view in its own file
- `#Preview` blocks at bottom of view files
- Private helpers as private extensions at file bottom

---

## Key ViewModel Properties

### Computed Properties
- `activeParticipants` — Filters out away participants
- `currentDriver` — Current participant at driver index
- `currentNavigator` — Next participant (index + 1)
- `statusText` — Timer countdown or state message
- `progress` — Normalized progress (0.0-1.0) for circular bar
- `canStart` — Whether timer can start

### State Properties
- `participants`, `settings`, `state`, `remainingSeconds`
- `currentDriverIndex`, `rotationCount`
- `showingSettings`, `showRotationFlash`, `showRotationWindow`

---

## Quick Reference

### Build Commands

```bash
# Via XcodeBuildMCP
discover_projs
build_macos --scheme "MobTimer" --configuration Release
clean_proj --scheme "MobTimer"

# Direct xcodebuild
xcodebuild -workspace MobTimer.xcworkspace -scheme MobTimer -configuration Release build
```

### Common Build Errors

| Error | Solution |
|-------|----------|
| `Sendable closure captures non-Sendable type` | Add `@Sendable` to closure or mark type as `Sendable` |
| `Main actor-isolated property cannot be referenced` | Add `@MainActor` to containing type or use `await MainActor.run {}` |
| `Macro validation failed` | Build with `SKIP_MACRO_VALIDATION=YES` |
| `Code signing error` | Configure signing in Xcode before using XcodeBuildMCP |
