import SwiftUI

struct CompletionView: View {
    let recipeName: String

    @State private var showConfetti = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showPhotoFrame = false

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 48)

                headerSection

                Spacer().frame(height: 44)

                completionCard

                Spacer()

                takePhotoButton

                Spacer().frame(height: 36)
            }
            .padding(.horizontal, 24)

            if showConfetti {
                ConfettiView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage)
        }
        .onChange(of: capturedImage) { newImage in
            if newImage != nil {
                showPhotoFrame = true
            }
        }
        .navigationDestination(isPresented: $showPhotoFrame) {
            if let image = capturedImage {
                PhotoFrameView(photo: image, recipeName: recipeName)
            }
        }
        .onAppear {
            showConfetti = true
        }
    }

    private var headerSection: some View {
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

            Spacer().frame(height: 10)

            Text("Recipe Completed")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color("TextColor"))

            Text("You cooked it together.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("SecondaryTextColor"))
        }
    }

    private var completionCard: some View {
        VStack(spacing: 22) {
            cookingIcon

            VStack(spacing: 8) {
                Text("Great Job!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("TextColor"))

                Text(recipeName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("AccentColor"))
                    .multilineTextAlignment(.center)

                Text("Your meal is ready.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("SecondaryTextColor"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.62))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color("SecondaryColor").opacity(0.9), lineWidth: 1)
        )
        .shadow(
            color: Color("AccentColor").opacity(0.12),
            radius: 18,
            x: 0,
            y: 10
        )
    }

    private var cookingIcon: some View {
        ZStack {
            Circle()
                .fill(Color("AccentColor").opacity(0.14))
                .frame(width: 96, height: 96)

            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 62, weight: .bold))
                .foregroundColor(Color("AccentColor"))
                .scaleEffect(showConfetti ? 1.0 : 0.8)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.68),
                    value: showConfetti
                )
        }
    }

    private var takePhotoButton: some View {
        Button {
            showCamera = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "camera.fill")
                Text("Take a Photo")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("AccentColor"))
            .cornerRadius(18)
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false

    private let colors: [Color] = [
        Color("AccentColor"),
        Color("PrimaryColor"),
        Color("SecondaryColor"),
        .orange,
        .yellow
    ]

    var body: some View {
        ZStack {
            ForEach(0..<36, id: \.self) { index in
                ConfettiPiece(color: colors[index % colors.count])
                    .offset(
                        x: CGFloat.random(in: -190...190),
                        y: animate ? 900 : -120
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .linear(duration: Double.random(in: 2.2...3.8))
                        .delay(Double.random(in: 0...0.45)),
                        value: animate
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 8, height: 12)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
    }
}
