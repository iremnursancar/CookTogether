import Foundation
import Combine

class RoomManagementViewModel: ObservableObject {
    @Published var roomCode: String?
    @Published var navigateToWaitingLobby = false
    @Published var showJoinKitchen = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var navigateToJoinKitchen = false
    
    private let firebaseService = FirebaseService.shared
    
    func createKitchen() {
        guard let userName = UserDefaults.standard.string(forKey: "user_display_name") else {
            showError(message: "User name not found")
            return
        }
        
        firebaseService.createRoom(creatorName: userName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let code):
                    self?.roomCode = code
                    self?.navigateToWaitingLobby = true
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

//
//  RoomManagementViewModel.swift
//  CookTogether
//
//  Created by irem nur sancar on 16.03.2026.
//

