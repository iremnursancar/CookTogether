# Agent Instructions for CookTogether

## Project Context
CookTogether is an iOS cooking app that enables couples and friends to cook together through synchronized, step-by-step recipe guidance. The app divides tasks between two users in real-time using Firebase, creating a collaborative cooking experience while challenging traditional gender roles around cooking.

## Tech Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Backend**: Firebase Realtime Database
- **iOS Version**: iOS 16.0+
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependency Management**: Swift Package Manager (SPM)
- **Notifications**: UserNotifications framework
- **Camera/Photos**: AVFoundation, PhotosUI

## Project Structure
```
CookTogether/
├── Models/           # Data models (User, Room, Recipe, Step)
├── Views/            # SwiftUI views (screens)
├── ViewModels/       # View logic and state management
├── Services/         # Firebase, Storage, Notification services
├── Utilities/        # Helper functions, extensions
├── Resources/        # Assets, fonts, images
└── App/              # App entry point, configuration
```

## Coding Standards

### Naming Conventions
- **Files**: PascalCase (e.g., `RoomManagementView.swift`)
- **Classes/Structs**: PascalCase (e.g., `RoomViewModel`)
- **Variables/Functions**: camelCase (e.g., `selectedCharacter`, `joinRoom()`)
- **Constants**: camelCase with `k` prefix for global (e.g., `kMaxNameLength`)
- **Enums**: PascalCase for type, camelCase for cases

### SwiftUI Best Practices
- One view per file
- Extract complex views into separate components
- Use `@State` for local state, `@StateObject` for ViewModels
- Use `@Published` in ViewModels for observable properties
- Prefer `async/await` over completion handlers
- Use environment objects sparingly

### Firebase Conventions
- Database paths use kebab-case: `/rooms/{room-code}/users/{user-id}`
- All Firebase calls must be wrapped in error handling
- Use real-time listeners for synced data
- Clean up listeners in `onDisappear` or `deinit`

### Code Organization
- Group related functionality with `// MARK: - Section Name`
- Maximum function length: 30 lines (extract if longer)
- Prefer small, focused functions over large ones
- Add comments for complex logic only, code should be self-documenting

## Firebase Data Structure
```
/rooms/{roomCode}/
  ├── creatorName: String
  ├── partnerName: String
  ├── createdAt: Timestamp
  ├── status: "waiting" | "ready" | "cooking" | "complete"
  ├── selectedRecipe: String (recipeId)
  ├── cookingComplete: Boolean
  └── users/
      ├── {userId}/
          ├── name: String
          ├── selectedCharacter: "chef1" | "chef2"
          ├── isReady: Boolean
          ├── isReadyForCooking: Boolean
          ├── completedSteps: [String]
          ├── allStepsComplete: Boolean
          └── activeTimer: {startTime, duration}

/recipes/{recipeId}/
  ├── name: String
  ├── imageURL: String
  ├── cookingTime: Int (minutes)
  ├── description: String
  ├── ingredients: [String]
  └── steps/
      └── [{
          stepId: String,
          description: String,
          assignedTo: "user1" | "user2",
          duration: Int? (seconds, optional for timer steps)
         }]
```

## Error Handling
- All Firebase operations must use `do-catch` blocks
- Show user-friendly error messages (not technical details)
- Log errors to console for debugging: `print("Error: \(error.localizedDescription)")`
- Handle network failures gracefully with retry options
- Validate user input before Firebase operations

## Testing Requirements
- Unit tests for ViewModels and Services
- Test file naming: `{FileName}Tests.swift`
- Mock Firebase calls in tests (use protocols)
- Test edge cases: network failure, invalid input, concurrent updates
- Minimum coverage goal: 70%

## UI/UX Guidelines
- Use system fonts (SF Pro) unless specified
- Follow iOS Human Interface Guidelines
- Support portrait mode only
- Use haptic feedback for important actions (optional)
- Animations should be smooth (0.3s default duration)
- Loading indicators for operations > 0.5s
- Accessible UI: VoiceOver labels, sufficient contrast

## Performance Considerations
- Minimize Firebase read/write operations
- Cache recipe data locally after first fetch
- Optimize image loading (use async image loading)
- Debounce real-time updates if necessary
- Profile for memory leaks with Instruments

## Security & Privacy
- Never store sensitive data in UserDefaults
- Photos stored locally only (not uploaded to Firebase)
- Room codes expire after 24 hours of inactivity
- Request permissions with clear explanations
- Follow App Store privacy guidelines

## Quality Criteria
- ✅ No force-unwrapping (`!`) except in tests or guaranteed safe contexts
- ✅ All optionals handled with `if let`, `guard let`, or nil coalescing
- ✅ No hardcoded strings (use localization keys or constants)
- ✅ All public functions have documentation comments
- ✅ SwiftLint warnings resolved before commit
- ✅ Code compiles without warnings
- ✅ Real device testing for camera and notifications

## Implementation Notes
- Start with UI mockups before logic
- Implement Firebase structure first (test with hardcoded data)
- Build features incrementally (Story by Story)
- Test on real device early (especially camera, notifications, real-time sync)
- Use Xcode Previews for rapid UI iteration
