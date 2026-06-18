import Foundation
import FirebaseDatabase
import Combine

class WaitingLobbyViewModel: ObservableObject {
    @Published var navigateToCharacterSelection = false
    @Published var shouldDismiss = false
    
    private var roomCode: String = ""
    private let database = Database.database().reference()
    private var roomRef: DatabaseReference?
    
    func startListening(roomCode: String) {
        self.roomCode = roomCode
        roomRef = database.child("rooms").child(roomCode)
        
        roomRef?.child("status").observe(.value) { [weak self] snapshot in
            guard let status = snapshot.value as? String else { return }
            
            if status == "ready" {
                DispatchQueue.main.async {
                    self?.navigateToCharacterSelection = true
                }
            }
        }
    }
    
    func stopListening() {
        roomRef?.removeAllObservers()
    }
    
    deinit {
        stopListening()
    }
    func leaveRoom() {
        guard !roomCode.isEmpty else { return }
        
        // Firebase'den room'u sil
        database.child("rooms").child(roomCode).removeValue()
        stopListening()
    }
}


//
//  WaitingLobbyViewModel.swift
//  CookTogether
//
//  Created by irem nur sancar on 16.03.2026.
//

