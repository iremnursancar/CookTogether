import Foundation
import FirebaseDatabase
import Combine
import UserNotifications
import UIKit

class CookingViewModel: ObservableObject {
    @Published var recipe: Recipe?
    @Published var mySteps: [RecipeStep] = []
    @Published var partnerSteps: [RecipeStep] = []
    @Published var partnerCompletedStepIds: Set<String> = []
    @Published var partnerName: String = "Partner"
    @Published var partnerCharacter: String = "chef1"
    @Published var partnerCurrentStep: RecipeStep?
    @Published var partnerCompletedAll: Bool = false
    @Published var currentStepIndex: Int = 0
    @Published var completedSteps: Int = 0
    @Published var totalSteps: Int = 0
    @Published var progress: Double = 0.0
    @Published var navigateToCompletion = false
    @Published var activeTimerStepId: String?
    @Published var remainingTime: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var showTimerAlert: Bool = false

    private var timer: Timer?
    private var timerStartTime: Date?
    private var timerOriginalDuration: Int = 0
    private var roomCode: String = ""
    private var recipeId: String = ""
    private var userId: String = ""
    private var completedStepIds: Set<String> = []
    private let database = Database.database().reference()
    private var roomRef: DatabaseReference?
    
    func setup(roomCode: String, recipeId: String) {
        self.roomCode = roomCode
        self.recipeId = recipeId
        self.userId = getUserId()
        self.roomRef = database.child("rooms").child(roomCode)
        
        requestNotificationPermission()
        
        fetchRecipe()
        fetchPartnerName()
        startListening()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            }
        }
    }
    
    func completeStep(_ stepId: String) {
        guard !completedStepIds.contains(stepId) else { return }
        
        if activeTimerStepId == stepId {
            stopTimer()
        }
        
        completedStepIds.insert(stepId)
        
        roomRef?.child("users").child(userId).child("completedSteps").child(stepId).setValue(true)
        
        updateProgress()
        moveToNextStep()
    }
    
    func isStepCompleted(_ stepId: String) -> Bool {
        completedStepIds.contains(stepId)
    }
    
    func isPartnerStepCompleted(_ stepId: String) -> Bool {
        partnerCompletedStepIds.contains(stepId)
    }
    
    func partnerCharacterEmoji() -> String {
        partnerCharacter == "chef1" ? "👨‍🍳" : "👩‍🍳"
    }
    
    func partnerActivityText() -> String {
        guard let step = partnerCurrentStep else { return "" }
        
        let description = step.description.lowercased()
        
        let cleanedDescription = description
            .replacingOccurrences(of: "boil ", with: "boiling ")
            .replacingOccurrences(of: "slice ", with: "slicing ")
            .replacingOccurrences(of: "chop ", with: "chopping ")
            .replacingOccurrences(of: "mix ", with: "mixing ")
            .replacingOccurrences(of: "sauté ", with: "sautéing ")
            .replacingOccurrences(of: "add ", with: "adding ")
            .replacingOccurrences(of: "cut ", with: "cutting ")
            .replacingOccurrences(of: "cook ", with: "cooking ")
        
        return cleanedDescription
    }
    
    // TIMER FUNCTIONS
    func startTimer(for stepId: String, duration: Int) {
        activeTimerStepId = stepId
        remainingTime = duration
        timerOriginalDuration = duration
        isTimerRunning = true
        timerStartTime = Date()
        
        scheduleTimerNotification(in: TimeInterval(duration))
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cookingTimer"])
    }
    
    func resumeTimer() {
        guard remainingTime > 0 else { return }
        isTimerRunning = true
        timerStartTime = Date().addingTimeInterval(-TimeInterval(timerOriginalDuration - remainingTime))
        
        scheduleTimerNotification(in: TimeInterval(remainingTime))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        activeTimerStepId = nil
        remainingTime = 0
        timerStartTime = nil
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cookingTimer"])
    }
    
    func checkTimerStatus() {
        guard let startTime = timerStartTime,
              activeTimerStepId != nil else { return }
        
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let newRemainingTime = max(0, timerOriginalDuration - elapsed)
        
        if newRemainingTime <= 0 {
            DispatchQueue.main.async {
                self.timerFinished()
            }
        } else {
            DispatchQueue.main.async {
                self.remainingTime = newRemainingTime
            }
        }
    }
    
    private func timerTick() {
        guard let startTime = timerStartTime else { return }
        
        let elapsed = Int(Date().timeIntervalSince(startTime))
        remainingTime = max(0, timerOriginalDuration - elapsed)
        
        if remainingTime <= 0 {
            timerFinished()
        }
    }
    
    private func timerFinished() {
        isTimerRunning = false
        timer?.invalidate()
        showTimerAlert = true
        timerStartTime = nil
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func scheduleTimerNotification(in seconds: TimeInterval) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cookingTimer"])
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished! ⏰"
        content.body = "Your cooking timer has completed."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "cookingTimer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func fetchRecipe() {
        database.child("recipes").child(recipeId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let recipeData = snapshot.value as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: recipeData),
                  let recipe = try? JSONDecoder().decode(Recipe.self, from: jsonData) else { return }
            
            DispatchQueue.main.async {
                self.recipe = recipe
                self.filterMySteps()
            }
        }
    }
    
    private func filterMySteps() {
        guard let recipe = recipe else { return }
        
        checkUserAssignment { [weak self] isUser1 in
            guard let self = self else { return }
            
            let myAssignment = isUser1 ? "user1" : "user2"
            let partnerAssignment = isUser1 ? "user2" : "user1"
            
            DispatchQueue.main.async {
                self.mySteps = recipe.steps.filter { $0.assignedTo == myAssignment }
                self.partnerSteps = recipe.steps.filter { $0.assignedTo == partnerAssignment }
                self.totalSteps = self.mySteps.count
                self.updateProgress()
                self.updatePartnerCurrentStep()
            }
        }
    }
    
    private func checkUserAssignment(completion: @escaping (Bool) -> Void) {
        roomRef?.child("users").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let users = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            let userIds = Array(users.keys).sorted()
            let isUser1 = userIds.first == self.userId
            completion(isUser1)
        }
    }
    
    private func fetchPartnerName() {
        roomRef?.child("creatorName").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let creatorName = snapshot.value as? String,
               let myName = UserDefaults.standard.string(forKey: "user_display_name") {
                
                if creatorName != myName {
                    DispatchQueue.main.async {
                        self.partnerName = creatorName
                        // ← EKLE: UserDefaults'a kaydet
                        UserDefaults.standard.set(creatorName, forKey: "partner_name")
                    }
                } else {
                    self.roomRef?.child("partnerName").observeSingleEvent(of: .value) { snapshot in
                        if let partnerName = snapshot.value as? String {
                            DispatchQueue.main.async {
                                self.partnerName = partnerName
                                // ← EKLE: UserDefaults'a kaydet
                                UserDefaults.standard.set(partnerName, forKey: "partner_name")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updatePartnerCurrentStep() {
        partnerCurrentStep = partnerSteps.first { step in
            !partnerCompletedStepIds.contains(step.id)
        }
        
        partnerCompletedAll = partnerSteps.allSatisfy { step in
            partnerCompletedStepIds.contains(step.id)
        }
    }
    
    private func updateProgress() {
        completedSteps = completedStepIds.count
        progress = totalSteps > 0 ? Double(completedSteps) / Double(totalSteps) : 0.0
    }
    
    private func moveToNextStep() {
        if currentStepIndex < mySteps.count - 1 {
            currentStepIndex += 1
        }
    }
    
    private func startListening() {
        roomRef?.child("users").observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let users = snapshot.value as? [String: [String: Any]] else { return }
            
            for (uid, userData) in users {
                if uid != self.userId {
                    if let character = userData["selectedCharacter"] as? String {
                        DispatchQueue.main.async {
                            self.partnerCharacter = character
                        }
                    }
                    
                    if let completedSteps = userData["completedSteps"] as? [String: Bool] {
                        DispatchQueue.main.async {
                            self.partnerCompletedStepIds = Set(completedSteps.keys)
                            self.updatePartnerCurrentStep()
                        }
                    }
                }
            }
            
            self.checkBothCompleted(users: users)
        }
    }
    
    private func checkBothCompleted(users: [String: [String: Any]]) {
        var myCompleted = false
        var partnerCompleted = false
        
        for (uid, userData) in users {
            if let completedSteps = userData["completedSteps"] as? [String: Bool] {
                let completedCount = completedSteps.count
                
                if uid == self.userId {
                    myCompleted = (completedCount == self.mySteps.count)
                } else {
                    partnerCompleted = (completedCount == self.partnerSteps.count)
                }
            }
        }
        
        if myCompleted && partnerCompleted {
            DispatchQueue.main.async {
                self.navigateToCompletion = true
            }
        }
    }
    
    private func getUserId() -> String {
        if let existingId = UserDefaults.standard.string(forKey: "userId") {
            return existingId
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "userId")
        return newId
    }
    
    deinit {
        timer?.invalidate()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cookingTimer"])
        roomRef?.removeAllObservers()
    }
}
