import SwiftUI

struct JoinKitchenView: View {
    @StateObject private var viewModel = JoinKitchenViewModel()
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {

            ZStack {

                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.35))
                                )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 8)

                    Spacer()
                }
                

                VStack(spacing: 0) {

                    Spacer().frame(height: 60)

                    // MARK: Logo

                    HStack(spacing: 4) {

                        Image("SplashLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)

                        HStack(spacing: 0) {
                            Text("Cook")
                                .foregroundColor(Color("TextColor"))

                            Text("Together")
                                .foregroundColor(Color("AccentColor"))
                        }
                        .font(.system(size: 28, weight: .bold))
                    }

                    Spacer().frame(height: 24)

                    // MARK: Title

                    Text("Join Kitchen")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color("TextColor"))

                    Spacer().frame(height: 8)

                    Text("Enter the kitchen code")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))

                    Spacer().frame(height: 48)

                    // MARK: Code Boxes

                    ZStack {

                        TextField("", text: $viewModel.code)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .focused($isFocused)
                            .opacity(0.01)
                            .frame(width: 1, height: 1)
                            .onChange(of: viewModel.code) { value in

                                let filtered = value.filter { $0.isNumber }

                                if filtered.count > 4 {
                                    viewModel.code = String(filtered.prefix(4))
                                } else {
                                    viewModel.code = filtered
                                }
                            }

                        HStack(spacing: 14) {

                            ForEach(0..<4, id: \.self) { index in

                                let character =
                                    index < viewModel.code.count
                                    ? String(Array(viewModel.code)[index])
                                    : ""

                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.65))
                                    .frame(width: 68, height: 78)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                index == viewModel.code.count
                                                ? Color("AccentColor")
                                                : Color("SecondaryColor"),
                                                lineWidth: 2
                                            )
                                    )
                                    .overlay(
                                        Text(character)
                                            .font(
                                                .system(
                                                    size: 34,
                                                    weight: .bold,
                                                    design: .rounded
                                                )
                                            )
                                            .foregroundColor(
                                                Color("TextColor")
                                            )
                                    )
                            }
                        }
                    }
                    .onTapGesture {
                        isFocused = true
                    }

                    Spacer().frame(height: 32)

                    // MARK: Join Button

                    Button {
                        viewModel.joinKitchen()
                    } label: {

                        Text("Join Kitchen")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                viewModel.isValid
                                ? Color("AccentColor")
                                : Color.gray.opacity(0.5)
                            )
                            .cornerRadius(18)
                    }
                    .disabled(!viewModel.isValid)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                isFocused = true
            }
            .alert("Error", isPresented: $viewModel.showError) {

                Button("OK") { }

            } message: {

                Text(viewModel.errorMessage ?? "")
            }
            .navigationDestination(
                isPresented: $viewModel.navigateToCharacterSelection
            ) {
                CharacterSelectionView(roomCode: viewModel.code)
            }
        }
    }
}
