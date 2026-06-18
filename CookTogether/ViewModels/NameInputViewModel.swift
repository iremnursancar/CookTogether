import Foundation
import Combine

final class NameInputViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            validateName()
        }
    }

    @Published private(set) var isValid: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published var didFinish: Bool = false

    private let userDefaultsKey = "user_display_name"
    private let minLength = 1
    private let maxLength = 20

    init() {
        loadExistingName()
    }

    func onContinueTapped() {
        guard isValid else { return }
        saveName()
        didFinish = true
    }

    private func loadExistingName() {
        if let existing = UserDefaults.standard.string(forKey: userDefaultsKey) {
            name = existing
        }
    }

    private func saveName() {
        UserDefaults.standard.set(name, forKey: userDefaultsKey)
    }

    private func validateName() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            isValid = false
            return
        }
        
        guard trimmed.count >= minLength, trimmed.count <= maxLength else {
            isValid = false
            return
        }
        
        let pattern = "^[A-Za-z0-9 ]{1,20}$"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.utf16.count)) != nil else {
            isValid = false
            return
        }
        
        isValid = true
    }
    }
//
//  NameInputViewModel.swift
//  CookTogether
//
//  Created by irem nur sancar on 15.03.2026.
//

