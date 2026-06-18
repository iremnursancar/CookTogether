import Foundation
import FirebaseDatabase
import Combine

class CharacterSelectionViewModel: ObservableObject {
    @Published var selectedCharacter: String?
    @Published var partnerCharacter: String?
    @Published var isReadyButtonEnabled = false
    @Published var navigateToRecipeSelection = false
    
    private var roomCode: String = ""
    private var userId: String = ""
    private let database = Database.database().reference()
    private var roomRef: DatabaseReference?
    
    func setup(roomCode: String) {
        self.roomCode = roomCode
        self.userId = getUserId()
        
        if let userName = UserDefaults.standard.string(forKey: "user_display_name") {
            database.child("rooms").child(roomCode)
                .child("users").child(userId)
                .child("userName").setValue(userName)
        }

        
        startListening()
    }
    
    func selectCharacter(_ characterId: String) {
        selectedCharacter = characterId
        isReadyButtonEnabled = true
        
        // Save to Firebase
        roomRef?.child("users").child(userId).child("selectedCharacter").setValue(characterId)
    }
    
    func toggleCharacter(_ characterId: String) {
        if selectedCharacter == characterId {
            // Unselect
            selectedCharacter = nil
            isReadyButtonEnabled = false
            roomRef?.child("users").child(userId).child("selectedCharacter").removeValue()
        } else {
            // Select
            selectedCharacter = characterId
            isReadyButtonEnabled = true
            roomRef?.child("users").child(userId).child("selectedCharacter").setValue(characterId)
        }
    }
    
    func confirmSelection() {
        guard selectedCharacter != nil else { return }
        
        let userName = UserDefaults.standard.string(forKey: "user_display_name") ?? "User"
        
        roomRef?.child("users").child(userId).child("isReady").setValue(true)
        roomRef?.child("users").child(userId).child("userName").setValue(userName)  // ← EKLE
    }
    
    private func startListening() {
        roomRef = database.child("rooms").child(roomCode)
        
        // Listen to partner's character selection
        roomRef?.child("users").observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let users = snapshot.value as? [String: [String: Any]] else { return }
            
            // Find partner's character
            for (uid, userData) in users {
                if uid != self.userId,
                   let character = userData["selectedCharacter"] as? String {
                    DispatchQueue.main.async {
                        self.partnerCharacter = character
                    }
                }
                
                // Check if both ready
                if uid != self.userId,
                   let isReady = userData["isReady"] as? Bool,
                   isReady,
                   let myReady = users[self.userId]?["isReady"] as? Bool,
                   myReady {
                    DispatchQueue.main.async {
                        self.navigateToRecipeSelection = true
                    }
                }
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
        roomRef?.removeAllObservers()
    }
}
