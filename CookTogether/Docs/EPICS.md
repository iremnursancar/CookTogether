# Epic 1: Room Management

## Description
Enable users to create a cooking room, generate a shareable code, and allow their partner to join the same room. The room serves as the coordination space where both users will cook together in sync.

## User Value
Users can quickly set up a shared cooking session without authentication or complex setup. The simple code-sharing mechanism makes it easy for couples and friends to connect and start cooking together.

## Workflow
1. User opens app and enters their name
2. User selects "Create Room" or "Join Room"
3. If Create: App generates unique 4-digit room code, displays "Waiting for partner"
4. If Join: User enters 4-digit room code, validates, and joins
5. When both users are in room, automatically navigate to Character Selection

## Acceptance Criteria
✅ Room code is unique (4-digit numeric)
✅ Room creator sees "Waiting for partner" screen
✅ Partner can join with correct code within 1 minute
✅ Both users automatically redirected when partner joins
✅ Invalid code shows error message
✅ Room data syncs via Firebase in real-time

## Stories
- Story 1.1: Display name input screen
- Story 1.2: Create room and generate code
- Story 1.3: Join room with code
- Story 1.4: Waiting lobby with real-time sync


# Epic 2: Pre-Cooking Setup

## Description
After both users join the room, they select their chef characters and choose a recipe together. This setup phase ensures both users are aligned on what they'll cook and who they'll represent in the app.

## User Value
Users personalize their experience through character selection and collaboratively decide what to cook, creating buy-in and excitement before starting.

## Workflow
1. Both users arrive at Character Selection screen
2. Each user selects one of 2 available chef characters
3. Users can tap different character to change selection
4. Each user confirms selection with "Ready" button
5. When both ready, navigate to Recipe Selection
6. Room creator browses 3-5 pre-loaded recipes
7. Creator can tap different recipe to change selection
8. Creator selects a recipe, partner sees selection
9. Both users confirm "Ready" to start cooking

## Acceptance Criteria
✅ 2 distinct chef characters available for selection
✅ Users can tap different character to change selection before confirming
✅ Users cannot select the same character
✅ "Ready" button appears after character selection
✅ Recipe list shows 3-5 recipes with preview (ingredients, image)
✅ Creator can tap different recipe to change selection before confirming
✅ Only room creator can select recipe
✅ Partner sees selected recipe in real-time
✅ Both users must confirm ready before proceeding to cooking

## Stories
- Story 2.1: Display character selection screen
- Story 2.2: Handle character selection and validation
- Story 2.3: Display recipe list with details
- Story 2.4: Recipe selection and confirmation


# Epic 3: Collaborative Cooking

## Description
Users follow their assigned tasks step-by-step in real-time synchronization. Each user sees their own tasks with progress tracking, can start timers for time-based steps, and monitors their partner's progress throughout the cooking session.

## User Value
Users stay coordinated and engaged throughout cooking with clear task division, real-time updates, and visual progress tracking. The synchronized experience makes cooking feel collaborative rather than solo.

## Workflow
1. Both users arrive at Cooking screen with their assigned tasks
2. Current step is highlighted and enlarged (zoom effect)
3. User reads step, performs action, taps "Complete" button
4. Completed step becomes smaller/transparent, next step zooms in
5. Progress bar updates with each completed step
6. For time-based steps (e.g., "Bake 30 min"), user taps "Start Timer"
7. Timer runs, notification fires when complete
8. User taps "Complete" to proceed
9. At bottom of screen, partner's current task is displayed in real-time
10. When both users complete all tasks, "Finish Cooking" button appears

## Acceptance Criteria
✅ Each user sees only their assigned tasks
✅ Current step is visually emphasized (larger text, highlighted)
✅ Completed steps become smaller and semi-transparent
✅ Progress bar accurately reflects completion percentage
✅ Timer steps show "Start Timer" button
✅ Timer notification fires when time expires
✅ Partner's current task displayed at bottom with real-time updates
✅ "Finish Cooking" button appears only when both users complete all tasks
✅ All updates sync via Firebase within 3 seconds

## Stories
- Story 3.1: Display step-by-step task list with zoom effect
- Story 3.2: Handle step completion and progress tracking
- Story 3.3: Implement timer functionality with notifications
- Story 3.4: Display partner progress in real-time
- Story 3.5: Enable finish cooking when both complete



# Epic 4: Completion & Memory

## Description
When both users finish cooking, they celebrate with a completion screen featuring confetti and their chef characters. Users can take a photo of their finished dish, which is automatically placed in a decorative frame, and save it as a memory of cooking together.

## User Value
Users feel a sense of accomplishment and can preserve their cooking experience as a shareable memory. The celebratory moment reinforces the positive, collaborative nature of the activity.

## Workflow
1. Both users tap "Finish Cooking" and navigate to Completion screen
2. Completion screen displays with confetti animation and chef characters
3. "Take Photo" button appears
4. User taps button, camera opens
5. User captures photo of finished dish
6. Photo is automatically placed inside decorative frame
7. "Save to Photos" button appears
8. User taps to save framed photo to device photo library
9. Success message confirms save

## Acceptance Criteria
✅ Completion screen shows confetti animation
✅ Both users' selected chef characters appear on screen
✅ "Take Photo" button opens device camera
✅ Captured photo fits within decorative frame automatically
✅ Frame includes personalized text: "Cooked with love by [Name1] & [Name2]"
✅ "Save to Photos" button saves framed image to device
✅ Camera permission is requested before opening camera
✅ Success message appears after successful save
✅ Frame design is visually appealing and consistent with app branding

## Stories
- Story 4.1: Display completion screen with animation
- Story 4.2: Implement photo capture with camera
- Story 4.3: Place photo in decorative frame
- Story 4.4: Save framed photo to device library



