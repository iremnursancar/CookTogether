# PRD: CookTogether

## 1. Overview
CookTogether is an iOS app that helps couples and friends cook together through synchronized, step-by-step recipe guidance. The app divides tasks between two users and tracks progress in real-time, making cooking a collaborative and fun shared activity while challenging traditional gender roles around cooking.

## 2. Problem Statement
Couples and friends who want to cook together often face challenges:
- One person ends up doing most of the work while the other feels unsure how to help
- Traditional recipes are designed for single-user execution, not collaborative cooking
- No clear task division leads to coordination issues and inefficiency
- Cooking feels like a chore rather than a fun, shared activity

This results in unequal participation, frustration, and missed opportunities for quality time together.

## 3. Goals
- Make cooking a collaborative, two-person activity with clear task division
- Provide synchronized, step-by-step guidance for both users
- Create a fun and engaging cooking experience with real-time progress tracking
- Enable couples and friends to build memories together through cooking
- Promote equal participation in the kitchen

## 4. Success Metrics
- 75% of users save completion photos as memories
- Users complete an average of 3+ recipes together within first month
- 85% recipe completion rate (users who start a recipe finish it)

## 5. User Personas

**Persona 1: Elif (Female, 26)**
- Lives with partner, wants to share household activities equally
- Comfortable in the kitchen but prefers cooking together
- Tech-savvy, expects smooth and intuitive UX
- Pain: Partner doesn't know how to help effectively in the kitchen

**Persona 2: Orcun (Male, 28)**
- Wants to participate in cooking but lacks confidence
- Willing to learn if given clear, simple instructions
- Appreciates visual guidance and step-by-step approach
- Pain: Feels unsure where to start, ends up just watching

## 6. User Stories (High-Level)

**Story 1: Room Creation & Joining**
As a user, I want to create a cooking room and share a code with my partner, so that we can start cooking together.

**Story 2: Character Selection**
As a user, I want to select a chef character, so that I feel represented in the cooking experience.

**Story 3: Recipe Selection**
As a room creator, I want to browse and select a recipe, so that my partner and I know what we're cooking.

**Story 4: Synchronized Cooking**
As a user, I want to see my tasks step-by-step and track my partner's progress in real-time, so that we stay coordinated.

**Story 5: Timer Management**
As a user, I want to start timers for time-based tasks, so that I don't overcook or undercook.

**Story 6: Completion & Memory**
As a user, I want to take a photo of our finished dish in a decorative frame, so that we can save our cooking memory.

## 7. Scope

### In Scope (MVP)
✅ Room creation with shareable code (4-6 digit)
✅ Room joining via code
✅ Name input (no authentication)
✅ Character selection (2 chef avatars)
✅ Recipe selection (3-5 pre-loaded recipes)
✅ Step-by-step task display for each user
✅ Real-time synchronization via Firebase
✅ Progress bar tracking
✅ Partner progress visibility
✅ Timer functionality with notifications
✅ Completion screen with photo frame
✅ Photo capture and save to device

### Out of Scope (Future)
❌ User authentication/login system
❌ User profile and history
❌ Recipe upload by users
❌ More than 2 users per room
❌ Social media sharing (Instagram, Twitter)
❌ Achievement/badge system
❌ Recipe rating and reviews
❌ Multi-language support
❌ Video guidance

## 8. Assumptions
- Users have stable internet connection during cooking sessions
- Both users have iOS devices (iPhone)
- Users are physically together in the same kitchen
- Recipes are pre-loaded in Firebase (not user-generated)
- Users grant camera and notification permissions when requested
- Users will use the app in portrait mode

## 9. Risks
- **Real-time sync failure**: If Firebase connection drops, users lose coordination
  - *Mitigation*: Show connection status indicator, allow manual refresh
  
- **Timer notifications not firing**: iOS may restrict background notifications
  - *Mitigation*: Request proper permissions upfront, test thoroughly on device
  
- **Unequal task distribution**: Some recipes may not divide tasks equally
  - *Mitigation*: Carefully design recipe task splits during content creation
  
- **Low recipe variety**: Only 3-5 recipes in MVP may limit reusability
  - *Mitigation*: Choose diverse recipes (pasta, dessert, stir-fry, etc.)

## 10. Non-Functional Requirements
- **iOS Version**: iOS 16.0 and above
- **Devices**: iPhone only (portrait mode)
- **Performance**: Real-time sync latency < 3 seconds
- **Offline behavior**: Show connection error, allow manual refresh
- **Photo storage**: Photos saved locally to device photo library only

## 11. Privacy & Data Handling
- **Photos**: Stored locally on user's device only, not uploaded to server
- **User data**: Only name and room session data stored temporarily in Firebase
- **Room data retention**: Room data deleted from Firebase 24 hours after last activity
- **Permissions**: Camera access (for photo), Notifications (for timers)

## 12. Edge Cases
- **Network loss**: Show "Connection Lost" banner, allow manual reconnect
- **Partner disconnects**: Notify remaining user, allow them to continue solo or wait
- **Room code collision**: Generate unique 6-digit codes, validate before creation
- **App backgrounded during timer**: iOS local notification fires when timer completes
