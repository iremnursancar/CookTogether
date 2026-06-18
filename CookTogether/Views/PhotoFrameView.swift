import SwiftUI
import AudioToolbox

struct PhotoFrameView: View {
    let photo: UIImage
    let recipeName: String

    @State private var showSaveButton = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var showSaveAlert = false

    private var userName: String {
        UserDefaults.standard.string(forKey: "user_display_name") ?? "You"
    }

    private var partnerName: String {
        UserDefaults.standard.string(forKey: "partner_name") ?? "Partner"
    }

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 40)
                .overlay(Color.black.opacity(0.6))

            VStack(spacing: 24) {
                Spacer()

                photoTemplate(width: 340)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .shadow(
                        color: .black.opacity(0.35),
                        radius: 22,
                        x: 0,
                        y: 12
                    )

                Spacer()

                if showSaveButton {
                    Button {
                        savePhotoToLibrary()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Save to Photos")
                        }
                        .frame(width: 260)
                        .padding(.vertical, 16)
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(Color("AccentColor"))
                        .cornerRadius(18)
                    }
                    
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Saved!", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Photo saved to your library!")
        }
        .onAppear {
            playCameraShutterSound()

            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                rotation = -3
                scale = 1.0
            }

            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                showSaveButton = true
            }
        }
    }

    private func photoTemplate(width: CGFloat) -> some View {
        let height = width * 1.5

        return ZStack(alignment: .topLeading) {

            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(
                    width: width * 0.69,
                    height: height * 0.60
                )
                .clipped()
                .offset(
                    x: width * 0.155,
                    y: height * 0.085
                )

            Image("polaroid_frame")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)

            VStack(spacing: 0) {

                Text("Made together by")
                    .font(.system(size: width * 0.034, weight: .medium))
                    .foregroundColor(Color("SecondaryTextColor"))

                Spacer().frame(height: height * 0.018)

                Text("\(userName) & \(partnerName)")
                    .font(.system(size: width * 0.05, weight: .semibold))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer().frame(height: height * 0.015)

                Text(currentDate)
                    .font(.system(size: width * 0.035, weight: .medium))
                    .foregroundColor(Color("SecondaryTextColor"))

                Spacer().frame(height: height * 0.045)

                HStack(spacing: 8) {
                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.085,
                            height: width * 0.085
                        )

                    HStack(spacing: 0) {
                        Text("Cook")
                            .foregroundColor(Color("TextColor"))

                        Text("Together")
                            .foregroundColor(Color("AccentColor"))
                    }
                    .font(.system(size: width * 0.056, weight: .bold))
                }
                .offset(y: -10)
            }
            .frame(width: width * 0.60)
            .offset(
                x: width * 0.20,
                y: height * 0.735
            )
        }
        .frame(width: width, height: height)
    }

    private func playCameraShutterSound() {
        AudioServicesPlaySystemSound(1108)
    }

    private func savePhotoToLibrary() {
        let renderer = ImageRenderer(
            content: photoTemplate(width: 1024)
        )

        renderer.scale = 1

        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(
                image,
                nil,
                nil,
                nil
            )

            showSaveAlert = true
        }
    }
}
