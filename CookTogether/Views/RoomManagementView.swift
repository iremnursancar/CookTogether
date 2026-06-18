import SwiftUI

struct RoomManagementView: View {
    @StateObject private var viewModel = RoomManagementViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    Spacer().frame(height: 28)

                    headerSection

                    Spacer().frame(height: 55)

                    VStack(spacing: 20) {
                        actionCard(
                            title: "Create Kitchen",
                            subtitle: "Start a new kitchen and invite your partner.",
                            icon: "plus",
                            isPrimary: true
                        ) {
                            viewModel.createKitchen()
                        }

                        actionCard(
                            title: "Join Kitchen",
                            subtitle: "Enter a kitchen code to join.",
                            icon: "person.2.fill",
                            isPrimary: false
                        ) {
                            viewModel.navigateToJoinKitchen = true
                        }
                    }

                    Spacer()

                    secureNote

                    Spacer().frame(height: 34)
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $viewModel.navigateToWaitingLobby) {
                WaitingLobbyView(roomCode: viewModel.roomCode ?? "")
            }
            .navigationDestination(isPresented: $viewModel.navigateToJoinKitchen) {
                JoinKitchenView()
            }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
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

            Text("Create or join a private kitchen.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("SecondaryTextColor"))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Cards

    private func actionCard(
        title: String,
        subtitle: String,
        icon: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button {
            action()
        } label: {

            HStack(spacing: 18) {

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isPrimary
                            ? Color("AccentColor")
                            : Color("AccentColor").opacity(0.12)
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(
                            isPrimary
                            ? .white
                            : Color("AccentColor")
                        )
                }

                VStack(alignment: .leading, spacing: 6) {

                    Text(title)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(Color("TextColor"))

                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(
                        isPrimary
                        ? .white
                        : Color("AccentColor")
                    )
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(
                                isPrimary
                                ? Color("AccentColor")
                                : Color("AccentColor").opacity(0.12)
                            )
                    )
            }
            .padding(22)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.62))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        Color("SecondaryColor").opacity(0.9),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color("AccentColor").opacity(
                    isPrimary ? 0.14 : 0.07
                ),
                radius: 18,
                x: 0,
                y: 10
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer

    private var secureNote: some View {
        HStack(spacing: 12) {

            Image(systemName: "lock.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("AccentColor"))
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(
                            Color("AccentColor")
                                .opacity(0.12)
                        )
                )

            Text("Your kitchen is private and secure.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("SecondaryTextColor"))

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.5))
        )
        .overlay(
            Capsule()
                .stroke(
                    Color("SecondaryColor").opacity(0.8),
                    lineWidth: 1
                )
        )
    }

