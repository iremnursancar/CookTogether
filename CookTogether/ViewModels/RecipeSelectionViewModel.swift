import Foundation
import FirebaseDatabase
import Combine

class RecipeSelectionViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var selectedRecipeId: String?
    @Published var isLoading = true
    @Published var isCreator = false
    @Published var isReadyButtonEnabled = false
    @Published var navigateToCooking = false

    private var roomCode: String = ""
    private var userId: String = ""
    private let database = Database.database().reference()
    private var roomRef: DatabaseReference?

    func setup(roomCode: String) {
        self.roomCode = roomCode
        self.userId = getUserId()
        checkIfCreator()
        fetchRecipes()
        startListening()
    }

    func selectRecipe(_ recipeId: String) {
        guard isCreator else { return }

        if selectedRecipeId == recipeId {
            selectedRecipeId = nil
            isReadyButtonEnabled = false
            roomRef?.child("selectedRecipe").removeValue()
        } else {
            selectedRecipeId = recipeId
            isReadyButtonEnabled = true
            roomRef?.child("selectedRecipe").setValue(recipeId)
        }
    }

    func confirmSelection() {
        guard selectedRecipeId != nil else { return }
        roomRef?.child("users").child(userId).child("isReadyForCooking").setValue(true)
    }

    private func fetchRecipes() {
        database.child("recipes").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            guard snapshot.exists(),
                  let recipeDict = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            var fetchedRecipes: [Recipe] = []

            for (_, value) in recipeDict {
                guard let data = value as? [String: Any] else { continue }

                let id = data["id"] as? String ?? UUID().uuidString
                let name = data["name"] as? String ?? "Untitled Recipe"
                let imageURL = data["imageURL"] as? String ?? ""
                let imageName = data["imageName"] as? String ?? "placeholder_food"
                let cookingTime = data["cookingTime"] as? Int ?? 0
                let difficulty = data["difficulty"] as? String ?? "Easy"
                let description = data["description"] as? String ?? ""
                let ingredients = data["ingredients"] as? [String] ?? []

                var steps: [RecipeStep] = []

                if let stepArray = data["steps"] as? [[String: Any]] {
                    for stepData in stepArray {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: stepData),
                           let step = try? JSONDecoder().decode(RecipeStep.self, from: jsonData) {
                            steps.append(step)
                        }
                    }
                }

                let recipe = Recipe(
                    id: id,
                    name: name,
                    imageURL: imageURL,
                    imageName: imageName,
                    cookingTime: cookingTime,
                    difficulty: difficulty,
                    description: description,
                    ingredients: ingredients,
                    steps: steps
                )

                fetchedRecipes.append(recipe)
            }

            DispatchQueue.main.async {
                self.recipes = fetchedRecipes.sorted { $0.name < $1.name }
                self.isLoading = false
            }
        }
    }

    private func startListening() {
        roomRef = database.child("rooms").child(roomCode)

        roomRef?.child("selectedRecipe").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let recipeId = snapshot.value as? String {
                    self.selectedRecipeId = recipeId

                    if !self.isCreator {
                        self.isReadyButtonEnabled = true
                    }
                } else {
                    self.selectedRecipeId = nil
                    self.isReadyButtonEnabled = false
                }
            }
        }

        roomRef?.child("users").observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let users = snapshot.value as? [String: [String: Any]] else { return }

            var myReady = false
            var partnerReady = false

            for (uid, userData) in users {
                if let isReady = userData["isReadyForCooking"] as? Bool, isReady {
                    if uid == self.userId {
                        myReady = true
                    } else {
                        partnerReady = true
                    }
                }
            }

            if myReady && partnerReady {
                DispatchQueue.main.async {
                    self.navigateToCooking = true
                }
            }
        }
    }

    private func checkIfCreator() {
        roomRef = database.child("rooms").child(roomCode)

        roomRef?.child("creatorName").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let creatorName = snapshot.value as? String,
                  let userName = UserDefaults.standard.string(forKey: "user_display_name") else { return }

            DispatchQueue.main.async {
                self.isCreator = (creatorName == userName)
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
