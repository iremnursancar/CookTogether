import SwiftUI

struct RecipeSelectionView: View {
    let roomCode: String
    @StateObject private var viewModel = RecipeSelectionViewModel()
    @State private var selectedRecipe: Recipe?
    @State private var showRecipeDetail = false

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 22) {

                    HStack(spacing: 8) {
                        Image("SplashLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)

                        (
                            Text("Cook")
                                .foregroundColor(Color("TextColor"))
                            +
                            Text("Together")
                                .foregroundColor(Color("PrimaryColor"))
                        )
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a Recipe")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color("TextColor"))

                        Text(viewModel.isCreator
                             ? "Select a recipe and start cooking together."
                             : "Waiting for the kitchen creator to choose a recipe.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 18)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading recipes...")
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {
                            ForEach(viewModel.recipes) { recipe in
                                CTRecipeCard(
                                    recipe: recipe,
                                    isSelected: viewModel.selectedRecipeId == recipe.id,
                                    isCreator: viewModel.isCreator,
                                    onTap: {
                                        if viewModel.isCreator {
                                            viewModel.selectRecipe(recipe.id)
                                        }
                                    },
                                    onDetailTap: {
                                        selectedRecipe = recipe
                                        showRecipeDetail = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                }

                Button {
                    viewModel.confirmSelection()
                } label: {
                    Text("Ready")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(viewModel.isReadyButtonEnabled ? Color("AccentColor") : Color.gray.opacity(0.35))
                        )
                }
                .disabled(!viewModel.isReadyButtonEnabled)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showRecipeDetail) {
            if let recipe = selectedRecipe {
                CTRecipeDetailSheet(recipe: recipe)
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToCooking) {
            if let recipeId = viewModel.selectedRecipeId {
                CookingView(roomCode: roomCode, recipeId: recipeId)
            }
        }
        .onAppear {
            viewModel.setup(roomCode: roomCode)
        }
    }
}

struct CTRecipeCard: View {
    let recipe: Recipe
    let isSelected: Bool
    let isCreator: Bool
    let onTap: () -> Void
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(recipe.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                    .clipped()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("AccentColor"))
                        .background(Color.white.clipShape(Circle()))
                        .padding(14)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(recipe.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("TextColor"))

                Text(recipe.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color("SecondaryTextColor"))
                    .lineLimit(2)

                HStack(spacing: 16) {
                    Label("\(recipe.cookingTime) min", systemImage: "clock")
                    Label(recipe.difficulty, systemImage: "fork.knife")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("SecondaryTextColor"))

                HStack {
                    Button {
                        onDetailTap()
                    } label: {
                        Text("View Details")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("AccentColor"))
                    }

                    Spacer()

                    if !isCreator {
                        Text("Creator selects")
                            .font(.caption)
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                }
            }
            .padding(18)
        }
        .background(Color("CardColor"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(isSelected ? Color("AccentColor") : Color.clear, lineWidth: 2.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture {
            if isCreator {
                onTap()
            }
        }
        .opacity(isCreator ? 1.0 : 0.78)
    }
}

struct CTRecipeDetailSheet: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Image(recipe.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 28))

                    VStack(alignment: .leading, spacing: 10) {
                        Text(recipe.name)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color("TextColor"))

                        Text(recipe.description)
                            .font(.body)
                            .foregroundColor(Color("SecondaryTextColor"))

                        HStack(spacing: 14) {
                            Label("\(recipe.cookingTime) min", systemImage: "clock")
                            Label(recipe.difficulty, systemImage: "fork.knife")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("AccentColor"))
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Ingredients")
                            .font(.title2.bold())
                            .foregroundColor(Color("TextColor"))

                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("AccentColor"))

                                Text(ingredient)
                                    .foregroundColor(Color("TextColor"))
                            }
                        }
                    }
                    .padding(18)
                    .background(Color("CardColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .padding(24)
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
    }
}
