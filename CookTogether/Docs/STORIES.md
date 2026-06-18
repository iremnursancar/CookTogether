# CookTogether - User Stories

## EPIC 1: ROOM MANAGEMENT

### Story 1.1: Display name input screen

**User Story**
As a user, I want to enter my name when I first open the app, so that I can be identified in the cooking session.

**Description**
When the user opens the app for the first time (or after clearing data), they see a simple screen asking for their name. The name is stored locally and used throughout the session.

**Acceptance Criteria**
✅ Screen displays app logo at the top
✅ Text field labeled "What should we call you?" appears below logo
✅ Text field accepts alphanumeric input (max 20 characters)
✅ "Continue" button is disabled until name is entered (min 2 characters)
✅ Name is saved to UserDefaults when "Continue" is tapped
✅ User navigates to Room Management screen after saving

**Technical Notes**
- Use UserDefaults for local storage
- Validate input: trim whitespace, reject empty strings
- SwiftUI TextField with validation

**INVEST Check**
✅ Independent: Can be built standalone
✅ Negotiable: Character limit, validation rules can be adjusted
✅ Valuable: User can proceed to room creation
✅ Estimable: ~1 day
✅ Small: Single screen, simple logic
✅ Testable: Can verify name is saved and navigation works

---

### Story 1.2: Create room and generate code

**User Story**
As a user, I want to create a kitchen with a unique code, so that my partner can join me.

**Description**
User taps "Create Kitchen" button and the app generates a unique 4-digit kitchen code. The room is created in Firebase with the user as the creator, and the code is displayed on screen.

**Acceptance Criteria**
✅ "Create Kitchen" button is visible on screen
✅ Tapping button generates unique 4-digit numeric code
✅ Code is checked against Firebase for uniqueness before creation
✅ Room is created in Firebase with creator's name and timestamp
✅ User navigates to Waiting Lobby screen showing the kitchen code
✅ Kitchen code is displayed in large, readable font
✅ "Share Code" button copies code to clipboard

**Technical Notes**
- Firebase Realtime Database: `/rooms/{roomCode}`
- Generate random 4-digit code (0000-9999)
- Collision check: query Firebase before confirming
- Store: roomCode, creatorName, createdAt, status: "waiting"

**INVEST Check**
✅ Independent: Can be built without other features
✅ Negotiable: Code format, length can be adjusted
✅ Valuable: User can create a room
✅ Estimable: ~1-2 days
✅ Small: Single action, Firebase integration
✅ Testable: Can verify room creation and code uniqueness

---

### Story 1.3: Join room with code

**User Story**
As a user, I want to join a kitchen using a code, so that I can cook together with my partner.

**Description**
User taps "Join Kitchen" button, enters the 4-digit code provided by their partner, and joins the existing room in Firebase. If successful, both users navigate to Character Selection.

**Acceptance Criteria**
✅ "Join Kitchen" button is visible on screen
✅ Tapping button shows a text field for 4-digit code input
✅ Code input field accepts only numeric characters (max 4 digits)
✅ "Join" button is disabled until 4 digits are entered
✅ Valid code allows user to join room in Firebase
✅ Invalid code shows error message "Kitchen not found"
✅ After successful join, user's name is added to room in Firebase
✅ Both users automatically navigate to Character Selection screen

**Technical Notes**
- Firebase query: check if `/rooms/{enteredCode}` exists
- Update room: add partnerName, status: "ready"
- Listen for room status changes to trigger navigation
- Validation: numeric only, exactly 4 digits

**INVEST Check**
✅ Independent: Can be built separately from creation
✅ Negotiable: Error messages, validation can be refined
✅ Valuable: User can join partner's kitchen
✅ Estimable: ~1-2 days
✅ Small: Single screen, Firebase query
✅ Testable: Can verify join success and error handling

---

### Story 1.4: Waiting lobby with real-time sync

**User Story**
As a room creator, I want to see a waiting screen until my partner joins, so that I know the kitchen is ready when they arrive.

**Description**
After creating a room, the creator sees a waiting lobby displaying the kitchen code and a "Waiting for partner..." message. When the partner joins via Story 1.3, Firebase triggers real-time sync and both users automatically navigate to Character Selection.

**Acceptance Criteria**
✅ Waiting lobby displays kitchen code prominently
✅ "Waiting for partner..." message is shown below code
✅ "Share Code" button copies code to clipboard with confirmation
✅ Firebase listener detects when partner joins in real-time
✅ When partner joins, both users navigate to Character Selection within 2 seconds
✅ Loading indicator shows during navigation transition
✅ Room creator can cancel and return to main screen (optional escape)

**Technical Notes**
- Firebase listener: observe `/rooms/{roomCode}/status`
- When status changes to "ready", trigger navigation
- Use Combine or async/await for real-time updates
- Clean up listener when view disappears

**INVEST Check**
✅ Independent: Relies on Story 1.2 but can be built separately
✅ Negotiable: Waiting screen design, messaging can be adjusted
✅ Valuable: User knows when partner arrives
✅ Estimable: ~1 day
✅ Small: Single waiting state, Firebase listener
✅ Testable: Can verify navigation trigger and real-time sync

---

## EPIC 2: PRE-COOKING SETUP

### Story 2.1: Display character selection screen

**User Story**
As a user, I want to see available chef characters and select one, so that I can personalize my cooking experience.

**Description**
Both users arrive at Character Selection screen after joining the room. Screen displays 2 distinct chef character illustrations with a "Choose Your Chef!" prompt. Users can tap to select a character. If partner selects a character first, it appears disabled with reduced opacity.

**Acceptance Criteria**
✅ Screen displays "Choose Your Chef!" title at top
✅ 2 distinct chef character images are displayed side-by-side
✅ Characters are visually distinct (different colors, styles, or gender representation)
✅ Tapping a character highlights it with a border or selection indicator
✅ Tapping a different character changes selection
✅ Partner's selected character appears disabled (50% opacity, grayed out)
✅ Disabled character cannot be selected
✅ Real-time sync shows partner's selection within 2 seconds
✅ "Ready" button appears below characters after selection is made
✅ "Ready" button is disabled until a character is selected

**Technical Notes**
- Store character images in Assets.xcassets
- Use SwiftUI @State for selected character
- Character IDs: "chef1", "chef2"
- Firebase: store selectedCharacter in /rooms/{roomCode}/users/{userId}
- Listen to partner's character selection for real-time updates
- Visual feedback: border color change or scale animation for selected, opacity 0.5 for disabled

**INVEST Check**
✅ Independent: Can be built standalone
✅ Negotiable: Character designs, selection UI can be refined
✅ Valuable: User can personalize their experience
✅ Estimable: ~1-2 days
✅ Small: Single screen with real-time sync logic
✅ Testable: Can verify selection, disabled state, and real-time sync

---

### Story 2.2: Handle character selection and validation

**User Story**
As a user, I want my character selection to be saved and synchronized with my partner, so that we both know who chose which chef.

**Description**
When a user selects a character and taps "Ready", their choice is saved to Firebase and synced in real-time. The app validates that both users have selected different characters before allowing progression to Recipe Selection.

**Acceptance Criteria**
✅ Tapping "Ready" saves selected character to Firebase
✅ Character selection syncs to partner's screen within 2 seconds
✅ When both users tap "Ready", validation checks occur
✅ If both selected different characters, navigate to Recipe Selection
✅ Loading indicator shows during validation and navigation
✅ User can tap a different character before pressing "Ready" to change selection
✅ Firebase updates reflect character changes in real-time

**Technical Notes**
- Firebase path: `/rooms/{roomCode}/users/{userId}/selectedCharacter`
- Listen to both users' ready status: `/rooms/{roomCode}/users/{userId}/isReady`
- Validation logic: chef1 ≠ chef2 before navigation
- Use Combine or async/await for state management

**INVEST Check**
✅ Independent: Builds on Story 2.1
✅ Negotiable: Validation timing, error handling can be adjusted
✅ Valuable: Ensures proper character assignment
✅ Estimable: ~1 day
✅ Small: Firebase sync and validation logic
✅ Testable: Can verify sync, validation, and navigation

---

### Story 2.3: Display recipe list with details

**User Story**
As a room creator, I want to browse available recipes with previews, so that I can choose what my partner and I will cook together.

**Description**
After character selection, both users navigate to Recipe Selection screen. The room creator sees a list of 3-5 pre-loaded recipes with images, names, and a "Details" button. Tapping "Details" shows ingredients and brief description. Partner sees the same list but in view-only mode.

**Acceptance Criteria**
✅ Screen displays "Choose a Recipe" title at top
✅ 3-5 recipes are displayed in a scrollable list or grid
✅ Each recipe card shows: recipe image, recipe name, cooking time
✅ "Details" button on each recipe card
✅ Tapping "Details" shows modal/sheet with: full ingredient list, brief description
✅ Modal has "Close" button to return to recipe list
✅ Only room creator can select recipes (partner's selection is disabled)
✅ Partner sees same recipe list but cannot interact with selection

**Technical Notes**
- Store recipes in Firebase: `/recipes/{recipeId}`
- Recipe model: name, image URL, cookingTime, ingredients[], description, steps[]
- Use SwiftUI List or LazyVGrid for recipe display
- Modal: SwiftUI .sheet() for details view
- Check user role (creator vs partner) to enable/disable selection

**INVEST Check**
✅ Independent: Can be built separately
✅ Negotiable: Recipe card design, details layout can be refined
✅ Valuable: Users can preview recipes before selecting
✅ Estimable: ~1-2 days
✅ Small: Recipe list UI and modal view
✅ Testable: Can verify display, details modal, and role-based access

---

### Story 2.4: Recipe selection and confirmation

**User Story**
As a room creator, I want to select a recipe and confirm it with my partner, so that we can start cooking together.

**Description**
Room creator taps on a recipe to select it. Selection is highlighted and synced to partner's screen in real-time. Creator can change selection before confirming. When creator taps "Ready", partner also taps "Ready" to confirm, and both navigate to Cooking screen.

**Acceptance Criteria**
✅ Creator can tap a recipe card to select it
✅ Selected recipe is highlighted with border or background color
✅ Creator can tap a different recipe to change selection
✅ Selected recipe syncs to partner's screen within 2 seconds
✅ Partner sees creator's selected recipe highlighted (view-only)
✅ "Ready" button appears for both users after recipe is selected
✅ Both users must tap "Ready" to proceed
✅ When both ready, navigate to Cooking screen with selected recipe
✅ Loading indicator shows during navigation

**Technical Notes**
- Firebase path: `/rooms/{roomCode}/selectedRecipe`
- Store recipeId when creator selects
- Listen to selectedRecipe changes for partner sync
- Ready status: `/rooms/{roomCode}/users/{userId}/isReadyForCooking`
- Fetch full recipe data from `/recipes/{recipeId}` before navigation

**INVEST Check**
✅ Independent: Builds on Story 2.3
✅ Negotiable: Confirmation flow, timing can be adjusted
✅ Valuable: Users agree on what to cook
✅ Estimable: ~1 day
✅ Small: Selection logic and Firebase sync
✅ Testable: Can verify selection, sync, and confirmation flow

---

## EPIC 3: COLLABORATIVE COOKING

### Story 3.1: Display step-by-step task list with zoom effect

**User Story**
As a user, I want to see my assigned cooking tasks with the current step emphasized, so that I can focus on what I need to do next.

**Description**
Users navigate to Cooking screen and see their assigned tasks listed vertically. The current step is displayed larger and more prominent (zoom effect), while completed steps become smaller and semi-transparent. This creates a focused, progressive cooking experience.

**Acceptance Criteria**
✅ Recipe name is displayed at the top of screen
✅ Progress bar shows overall completion percentage below recipe name
✅ Current step is displayed with larger font size and bold text
✅ Future steps are displayed below in normal size
✅ Completed steps appear above current step with reduced opacity (30-50%)
✅ Completed steps are scaled down or have smaller font size
✅ Smooth animation when transitioning between steps (zoom in/out effect)
✅ Each step shows task description clearly
✅ "Complete" button appears below current step

**Technical Notes**
- Use SwiftUI ScrollView with VStack for task list
- @State for currentStepIndex to track progress
- Animation: .scaleEffect() and .opacity() modifiers
- Filter tasks by userId from Firebase: `/recipes/{recipeId}/steps` where assignedTo == userId
- Calculate progress: (completedSteps / totalSteps) * 100

**INVEST Check**
✅ Independent: Can be built standalone with mock data
✅ Negotiable: Animation style, sizing can be refined
✅ Valuable: User can see focused task guidance
✅ Estimable: ~2 days
✅ Small: Single screen with animation logic
✅ Testable: Can verify step display, zoom effect, and progress bar

---

### Story 3.2: Handle step completion and progress tracking

**User Story**
As a user, I want to mark steps as complete and track my progress, so that I can move through the recipe systematically.

**Description**
User taps "Complete" button after finishing a step. The completed step transitions to a smaller, semi-transparent state above, and the next step zooms into focus. Progress bar updates to reflect completion percentage. Changes sync to Firebase in real-time.

**Acceptance Criteria**
✅ "Complete" button is enabled for current step only
✅ Tapping "Complete" marks step as done in Firebase
✅ Completed step animates to smaller size and reduced opacity
✅ Next step animates into focus with zoom effect
✅ Progress bar updates smoothly to reflect new percentage
✅ Step completion syncs to Firebase within 2 seconds
✅ User cannot mark future steps as complete (sequential progression)
✅ If all user's steps are complete, "Finish Cooking" button appears (disabled until partner also completes)

**Technical Notes**
- Firebase path: `/rooms/{roomCode}/users/{userId}/completedSteps[]`
- Append stepId to completedSteps array on completion
- Listen to completedSteps changes for real-time sync
- Validate sequential completion: currentStepIndex + 1
- Progress calculation: completedSteps.count / userSteps.count
- Use withAnimation {} for smooth transitions

**INVEST Check**
✅ Independent: Builds on Story 3.1
✅ Negotiable: Animation timing, validation rules can be adjusted
✅ Valuable: User can progress through recipe
✅ Estimable: ~1-2 days
✅ Small: Completion logic and Firebase sync
✅ Testable: Can verify completion, progress update, and sync

---

### Story 3.3: Implement timer functionality with notifications

**User Story**
As a user, I want to start timers for time-based cooking steps and receive notifications when they complete, so that I don't overcook or undercook food.

**Description**
For steps that require waiting (e.g., "Bake for 30 minutes"), a "Start Timer" button appears instead of "Complete". User taps to start countdown. Timer runs in foreground and background. When time expires, notification fires and "Complete" button becomes available.

**Acceptance Criteria**
✅ Steps with time duration show "Start Timer" button
✅ Tapping "Start Timer" begins countdown display (MM:SS format)
✅ Timer counts down in real-time on screen
✅ "Complete Now" button appears below timer (allows early completion)
✅ User can tap "Complete Now" to skip remaining time and proceed
✅ Timer continues running when app is backgrounded
✅ Notification fires when timer reaches 00:00
✅ Notification includes recipe name and step description
✅ When timer completes naturally, "Complete" button appears
✅ Timer state syncs to Firebase (partner can see if timer is running)

**Technical Notes**
- Identify timer steps: check if step has `duration` field in Firebase
- Use iOS Timer or Combine for countdown logic
- Request notification permission on first timer use: UNUserNotificationCenter
- Schedule local notification: UNNotificationRequest with time interval
- Firebase path: `/rooms/{roomCode}/users/{userId}/activeTimer` (startTime, duration)
- Handle app lifecycle: save timer start time, recalculate on resume

**INVEST Check**
✅ Independent: Can be built separately with mock timer steps
✅ Negotiable: Timer UI, notification message can be refined
✅ Valuable: User can track time-based cooking steps
✅ Estimable: ~2-3 days (notification handling adds complexity)
✅ Small: Timer logic and notification setup
✅ Testable: Can verify countdown, notification, and background behavior

---

### Story 3.4: Display partner progress in real-time

**User Story**
As a user, I want to see my partner's current task and progress, so that we can stay coordinated during cooking.

**Description**
At the bottom of the Cooking screen, a dedicated section displays partner's current step in real-time. Shows partner's name, their chef character icon, and current task description (e.g., "Elif is chopping tomatoes"). Updates automatically as partner completes steps.

**Acceptance Criteria**
✅ Partner progress section is fixed at bottom of screen
✅ Section displays partner's chef character icon (small)
✅ Section displays partner's name
✅ Section displays partner's current step description
✅ Text format: "[Partner Name] is [current step description]"
✅ Updates in real-time within 2 seconds when partner completes a step
✅ If partner is on a timer step, shows "waiting for timer" or timer icon
✅ When partner completes all tasks, shows "[Partner Name] has finished!"

**Technical Notes**
- Firebase listener: `/rooms/{roomCode}/users/{partnerId}/completedSteps`
- Calculate partner's current step: steps[completedSteps.count]
- Use Combine or async/await for real-time updates
- Display partner's selectedCharacter icon from Assets
- Handle edge cases: partner disconnects, partner ahead/behind

**INVEST Check**
✅ Independent: Can be built with mock partner data
✅ Negotiable: Display format, messaging can be refined
✅ Valuable: Users stay coordinated and engaged
✅ Estimable: ~1-2 days
✅ Small: Bottom section UI with Firebase listener
✅ Testable: Can verify real-time updates and display accuracy

---

### Story 3.5: Enable finish cooking when both complete

**User Story**
As a user, I want to finish the cooking session when both my partner and I complete all our tasks, so that we can celebrate and save our memory.

**Description**
When a user completes their final step, a "Finish Cooking" button appears but is disabled until the partner also completes all their tasks. Once both users are done, the button becomes enabled. Tapping it navigates both users to the Completion screen.

**Acceptance Criteria**
✅ "Finish Cooking" button appears when user completes their last step
✅ Button is disabled (grayed out) if partner hasn't finished yet
✅ Text shows "Waiting for [Partner Name] to finish..." when disabled
✅ Firebase listener checks partner's completion status in real-time
✅ When both users complete all tasks, button becomes enabled for both
✅ Button changes to active state with "Finish Cooking!" text
✅ Tapping enabled button navigates both users to Completion screen
✅ Navigation happens simultaneously within 2 seconds

**Technical Notes**
- Firebase paths:
  - `/rooms/{roomCode}/users/{userId}/allStepsComplete` (boolean)
  - `/rooms/{roomCode}/cookingComplete` (boolean, set when both true)
- Listen to both users' completion status
- Validation: user.completedSteps.count == user.totalSteps.count
- Set cookingComplete: true when both users done
- Trigger navigation on cookingComplete change

**INVEST Check**
✅ Independent: Builds on Story 3.2 and 3.4
✅ Negotiable: Button states, messaging can be adjusted
✅ Valuable: Users know when to finish and proceed together
✅ Estimable: ~1 day
✅ Small: Button state logic and Firebase sync
✅ Testable: Can verify completion detection and synchronized navigation

---

## EPIC 4: COMPLETION & MEMORY

### Story 4.1: Display completion screen with animation

**User Story**
As a user, I want to see a celebratory completion screen after finishing cooking, so that I feel accomplished and rewarded for cooking together.

**Description**
When both users complete cooking, they navigate to a Completion screen featuring confetti animation (silent), both selected chef characters, and congratulatory messaging. The screen creates a positive, celebratory moment before photo capture.

**Acceptance Criteria**
✅ Screen displays confetti animation on load (silent, no sound)
✅ Both users' selected chef characters appear on screen (side-by-side or together)
✅ Congratulatory text displays: "Great job, [Name1] & [Name2]!"
✅ Recipe name is shown: "You cooked [Recipe Name] together!"
✅ Confetti animation plays for 2-3 seconds
✅ "Take Photo" button appears below the celebration content
✅ Screen has visually appealing design consistent with app branding

**Technical Notes**
- Use SwiftUI Canvas or Lottie for confetti animation (silent)
- Retrieve chef characters from Firebase: `/rooms/{roomCode}/users/{userId}/selectedCharacter`
- Retrieve recipe name from `/rooms/{roomCode}/selectedRecipe`
- Animation: Can use built-in SwiftUI effects or third-party library (ConfettiSwiftUI)
- Layout: VStack with celebratory content + button

**INVEST Check**
✅ Independent: Can be built with mock completion data
✅ Negotiable: Animation style, messaging can be refined
✅ Valuable: Users feel rewarded and celebrated
✅ Estimable: ~1-2 days
✅ Small: Celebration screen with animation
✅ Testable: Can verify animation, character display, and messaging

---

### Story 4.2: Implement photo capture with camera

**User Story**
As a user, I want to take a photo of our finished dish using my camera, so that I can capture the moment we cooked together.

**Description**
User taps "Take Photo" button on Completion screen. iOS camera opens with standard camera interface. User captures photo of their dish. Camera shutter sound plays automatically. Photo is returned to the app for frame placement.

**Acceptance Criteria**
✅ "Take Photo" button is visible on Completion screen
✅ Tapping button requests camera permission (if not already granted)
✅ Camera opens with standard iOS camera interface
✅ User can capture photo using camera shutter button
✅ Camera shutter sound plays when photo is taken (system default)
✅ Photo is captured and returned to app
✅ If camera permission is denied, show alert with instructions to enable in Settings
✅ User can retake photo if not satisfied (optional)

**Technical Notes**
- Use UIImagePickerController or PHPickerViewController for camera access
- Request permission: AVCaptureDevice.requestAccess(for: .video)
- Camera source type: .camera
- Handle permission denial: show alert with Settings deeplink
- Shutter sound: Automatic with iOS camera (system handles this)
- Return captured UIImage for Story 4.3

**INVEST Check**
✅ Independent: Can be built standalone
✅ Negotiable: Camera UI, retake option can be adjusted
✅ Valuable: User can capture their cooking result
✅ Estimable: ~1 day
✅ Small: Camera integration with permission handling
✅ Testable: Can verify camera launch, capture, and permission handling

---

### Story 4.3: Place photo in decorative frame

**User Story**
As a user, I want my captured photo to be placed in a decorative frame with our names, so that it looks special and memorable.

**Description**
After capturing photo, the app automatically composites it into a pre-designed decorative frame. The frame includes the photo, personalized text with both users' names, and visual design elements. The framed image is displayed on screen for preview.

**Acceptance Criteria**
✅ Captured photo is automatically placed inside decorative frame
✅ Photo is scaled/cropped to fit frame area while maintaining aspect ratio
✅ Frame includes text: "Cooked with love by [Name1] & [Name2]"
✅ Frame design is visually appealing (borders, colors, patterns)
✅ Frame design is consistent with app branding
✅ Framed image displays on screen after photo capture
✅ "Save to Photos" button appears below framed image
✅ User can retake photo if desired (returns to Story 4.2)

**Technical Notes**
- Create frame template as PNG with transparent center area
- Use Core Graphics or SwiftUI overlay to composite:
  1. Base frame image
  2. User's photo (scaled/centered)
  3. Text overlay with names
- Text rendering: Use SwiftUI Text or Core Graphics CGContext
- Final output: Single UIImage combining all layers
- Store frame template in Assets.xcassets

**INVEST Check**
✅ Independent: Can be built with mock photo
✅ Negotiable: Frame design, text placement can be refined
✅ Valuable: User gets beautiful, personalized memory
✅ Estimable: ~1-2 days
✅ Small: Image compositing logic
✅ Testable: Can verify frame application, text overlay, and scaling

---

### Story 4.4: Save framed photo to device library

**User Story**
As a user, I want to save the framed photo to my device, so that I can keep it as a memory and share it with others.

**Description**
User taps "Save to Photos" button and the framed image is saved to their device photo library. The app requests photo library permission if needed. Success message confirms the save.

**Acceptance Criteria**
✅ "Save to Photos" button is visible below framed image
✅ Tapping button requests photo library permission (if not already granted)
✅ Framed image is saved to device photo library
✅ Success message displays: "Saved to Photos!"
✅ If permission is denied, show alert with instructions to enable in Settings
✅ Saved image includes full frame with photo and personalized text
✅ Image quality is high resolution (not compressed/pixelated)

**Technical Notes**
- Request permission: PHPhotoLibrary.requestAuthorization()
- Save image: UIImageWriteToSavedPhotosAlbum() or PHPhotoLibrary.shared().performChanges()
- Handle permission states: authorized, denied, notDetermined
- Show success toast/alert after save
- Error handling: catch save failures and show error message
- Image format: PNG for quality, JPEG acceptable

**INVEST Check**
✅ Independent: Can be built with mock framed image
✅ Negotiable: Save format, success messaging can be adjusted
✅ Valuable: User can keep and share their memory
✅ Estimable: ~1 day
✅ Small: Photo library integration with permission handling
✅ Testable: Can verify save, permission handling, and success message
