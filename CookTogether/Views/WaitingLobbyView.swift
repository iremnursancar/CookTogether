import SwiftUI

struct WaitingLobbyView: View {
    let roomCode: String

    @StateObject private var viewModel = WaitingLobbyViewModel()
    @State private var copied = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer().frame(height: 28)

                // MARK: Header

                VStack(spacing: 8) {

                    HStack(spacing: 4) {

                        Image("SplashLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)

                        HStack(spacing: 0) {
                            Text("Cook")
                                .foregroundColor(Color("TextColor"))

                            Text("Together")
                                .foregroundColor(Color("AccentColor"))
                        }
                        .font(.system(size: 28, weight: .bold))
                    }

                    Spacer().frame(height: 6)

                    Text("Kitchen Lobby")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("TextColor"))

                    Text("Waiting for your partner to join")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))
                }

                Spacer().frame(height: 32)

                // MARK: Code Card

                VStack(spacing: 8) {

                    Text(roomCode)
                        .font(.system(size: 52, weight: .bold))
                        .tracking(4)
                        .foregroundColor(Color("TextColor"))

                    Text("Kitchen Code")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.62))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            Color("SecondaryColor"),
                            lineWidth: 1
                        )
                )

                Spacer().frame(height: 24)

                // MARK: Copy Button

                Button {

                    UIPasteboard.general.string = roomCode

                    copied = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }

                } label: {

                    HStack(spacing: 10) {

                        Image(systemName:
                                copied
                              ? "checkmark.circle.fill"
                              : "doc.on.doc")

                        Text(copied ? "Copied!" : "Copy Code")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("AccentColor"))
                    .cornerRadius(18)
                }

                Spacer().frame(height: 56)

                // MARK: Status Card

                VStack(spacing: 14) {

                    HStack(spacing: 8) {

                        Circle()
                            .fill(.orange)
                            .frame(width: 10, height: 10)

                        Text("Waiting for partner")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                    }

                    Text("You'll continue to character selection when your partner joins.")
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.center)

                    ProgressView()
                        .tint(Color("AccentColor"))
                        .scaleEffect(1.1)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.62))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            Color("SecondaryColor"),
                            lineWidth: 1
                        )
                )

                Spacer(minLength: 80)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {

            ToolbarItem(placement: .topBarLeading) {

                Button {
                    viewModel.leaveRoom()
                    dismiss()
                } label: {

                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("TextColor"))
                }
            }
        }
        .navigationDestination(
            isPresented: $viewModel.navigateToCharacterSelection
        ) {
            CharacterSelectionView(roomCode: roomCode)
        }
        .onAppear {
            viewModel.startListening(roomCode: roomCode)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}
