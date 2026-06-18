import SwiftUI

struct NameInputView: View {
    @StateObject private var viewModel = NameInputViewModel()
    @FocusState private var isFocused: Bool
    @State private var goNext = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    Color("BackgroundColor")
                        .ignoresSafeArea()

                    VStack {
                        Spacer().frame(height: 60)

                        VStack(spacing: 12) {
                            Image("SplashLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 95, height: 95)

                            HStack(spacing: 0) {
                                Text("Cook")
                                    .foregroundColor(Color("TextColor"))
                                Text("Together")
                                    .foregroundColor(Color("AccentColor"))
                            }
                            .font(.system(size: 34, weight: .bold))
                        }
                        .padding(.bottom, 32)
                        
                        VStack(spacing: 8) {
                            Text("What should we call you?")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("TextColor"))
                                .multilineTextAlignment(.center)

                            Text("Time to meet the chef!")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color("SecondaryTextColor"))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 52)

                        VStack(spacing: 6) {
                            TextField("Your name", text: $viewModel.name)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .focused($isFocused)
                                .foregroundColor(Color("TextColor"))
                                .font(.system(size: 26, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.35))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            isFocused ? Color("AccentColor") : Color("SecondaryColor").opacity(0.9),
                                            lineWidth: isFocused ? 2 : 1
                                        )
                                )
                                .animation(.easeInOut(duration: 0.2), value: isFocused)
                                .frame(maxWidth: 250)

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }

                        Spacer()

                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            viewModel.onContinueTapped()

                            if viewModel.isValid {
                                goNext = true
                            }
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 260)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.isValid ? Color("AccentColor") : Color.gray.opacity(0.3))
                                )
                                .shadow(
                                    color: viewModel.isValid ? Color("AccentColor").opacity(0.25) : .clear,
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .disabled(!viewModel.isValid)
                        .padding(.bottom, 40)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $goNext) {
                RoomManagementView()
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}
