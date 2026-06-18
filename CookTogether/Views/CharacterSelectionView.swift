import SwiftUI

struct CharacterSelectionView: View {
    let roomCode: String
    @StateObject private var viewModel = CharacterSelectionViewModel()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 12) {
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
                            
                            Text("Choose Your Chef!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("Select a chef and get ready to cook together.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("SecondaryTextColor"))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 28)
                        
                        CharacterCard(
                            imageName: "chef_mia",
                            title: "Chef Mia",
                            subtitle: "Ready to cook!",
                            characterId: "chef1",
                            accentColor: Color("AccentColor"),
                            isSelected: viewModel.selectedCharacter == "chef1",
                            isDisabled: viewModel.partnerCharacter == "chef1",
                            onTap: { viewModel.toggleCharacter("chef1") }
                        )
                        
                        CharacterCard(
                            imageName: "chef_leo",
                            title: "Chef Leo",
                            subtitle: "Let’s cook together!",
                            characterId: "chef2",
                            accentColor: Color("TextColor"),
                            isSelected: viewModel.selectedCharacter == "chef2",
                            isDisabled: viewModel.partnerCharacter == "chef2",
                            onTap: { viewModel.toggleCharacter("chef2") }
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                }
                
                Button {
                    viewModel.confirmSelection()
                } label: {
                    Text("Ready")
                        .font(.system(size: 18, weight: .bold))
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
        .navigationDestination(isPresented: $viewModel.navigateToRecipeSelection) {
            RecipeSelectionView(roomCode: roomCode)
        }
        .onAppear {
            viewModel.setup(roomCode: roomCode)
        }
    }
}

struct CharacterCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let characterId: String
    let accentColor: Color
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .opacity(isDisabled ? 0.28 : 1.0)

                VStack(alignment: .leading, spacing: 8) {

                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(isDisabled ? .gray : accentColor)

                    Text(isDisabled ? "Selected by partner." : subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                ? Color("AccentColor").opacity(0.045)
                : Color("CardColor")
            )
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(
                        isSelected
                        ? Color("AccentColor")
                        : Color.gray.opacity(0.18),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color("AccentColor"))
                        .background(
                            Circle().fill(.white)
                        )
                        .padding(10)
                }
            }
            .shadow(
                color: .black.opacity(0.06),
                radius: 10,
                x: 0,
                y: 6
            )
            .opacity(isDisabled ? 0.65 : 1.0)
        }
        .disabled(isDisabled)
    }
}
