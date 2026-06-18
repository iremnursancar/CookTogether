import Foundation
import Combine

class JoinKitchenViewModel: ObservableObject {
    @Published var code: String = "" {
        didSet {
            isValid = code.count == 4
        }
    }
    @Published var isValid: Bool = false
    @Published var navigateToCharacterSelection = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    func joinKitchen() {
        guard isValid else { return }
        guard let userName = UserDefaults.standard.string(forKey: "user_display_name") else {
            showError(message: "User name not found")
            return
        }
        
        firebaseService.joinRoom(code: code, partnerName: userName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateToCharacterSelection = true
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
//  JoinKitchenViewModel.swift
//  CookTogether
//
//  Created by irem nur sancar on 16.03.2026.
//

