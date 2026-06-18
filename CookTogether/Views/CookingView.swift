import SwiftUI

struct CookingView: View {
    let roomCode: String
    let recipeId: String
    @StateObject private var viewModel = CookingViewModel()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        headerSection
                        stepsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 130)
                }
                
                partnerStatusBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Timer Finished!", isPresented: $viewModel.showTimerAlert) {
            Button("OK") {
                viewModel.stopTimer()
            }
        } message: {
            Text("Your timer has finished!")
        }
        .navigationDestination(isPresented: $viewModel.navigateToCompletion) {
            CompletionView(recipeName: viewModel.recipe?.name ?? "")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.checkTimerStatus()
        }
        .onAppear {
            viewModel.setup(roomCode: roomCode, recipeId: recipeId)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                
                (
                    Text("Cook")
                        .foregroundColor(Color("TextColor"))
                    +
                    Text("Together")
                        .foregroundColor(Color("PrimaryColor"))
                )
                .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            
            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Text(viewModel.recipe?.name ?? "")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color("TextColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("\(viewModel.completedSteps) of \(viewModel.totalSteps) steps completed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.18))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(Color("AccentColor"))
                            .frame(width: geometry.size.width * viewModel.progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color("CardColor"))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        }
    }
    
    private var stepsSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(viewModel.mySteps.enumerated()), id: \.element.id) { index, step in
                StepCard(
                    step: step,
                    isActive: index == viewModel.currentStepIndex,
                    isCompleted: viewModel.isStepCompleted(step.id),
                    viewModel: viewModel,
                    onComplete: {
                        viewModel.completeStep(step.id)
                    }
                )
                .scaleEffect(index == viewModel.currentStepIndex ? 1.0 : 0.94)
                .animation(.spring(response: 0.3), value: viewModel.currentStepIndex)
            }
        }
    }
    
    private var partnerStatusBar: some View {
        VStack {
            if viewModel.partnerCompletedAll {
                partnerCard(
                    title: "\(viewModel.partnerName) completed all steps!",
                    subtitle: "Great teamwork!",
                    isCompleted: true
                )
            } else if viewModel.partnerCurrentStep != nil {
                partnerCard(
                    title: "\(viewModel.partnerName) is working on",
                    subtitle: viewModel.partnerActivityText().capitalizedFirstLetter(),
                    isCompleted: false
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }
    
    private func partnerCard(title: String, subtitle: String, isCompleted: Bool) -> some View {
        HStack(spacing: 12) {
            partnerAvatar
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isCompleted ? .green : Color("TextColor"))
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("SecondaryTextColor"))
                    .lineLimit(2)
                
                Text("right now")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("SecondaryTextColor").opacity(0.75))
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding(14)
        .background(Color("CardColor"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isCompleted ? Color.green.opacity(0.25) : Color.gray.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    private var partnerAvatar: some View {
        Image(partnerImageName())
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .clipShape(Circle())
    }
    
    private func partnerImageName() -> String {
        if viewModel.partnerCharacter == "chef1" {
            return "chef_mia"
        } else {
            return "chef_leo"
        }
    }
}

struct StepCard: View {
    let step: RecipeStep
    let isActive: Bool
    let isCompleted: Bool
    @ObservedObject var viewModel: CookingViewModel
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                stepBadge
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Step \(stepNumber(step.id))")
                        .font(.system(size: isActive ? 22 : 17, weight: .bold))
                        .foregroundColor(isCompleted ? Color("SecondaryTextColor") : Color("TextColor"))
                    
                    Text(step.description)
                        .font(.system(size: isActive ? 17 : 15, weight: .medium))
                        .foregroundColor(isCompleted ? Color("SecondaryTextColor") : Color("TextColor"))
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(isCompleted ? 0.55 : 1.0)
                        .strikethrough(isCompleted, color: .gray)
                }
                
                Spacer()
                
                if let duration = step.duration, duration > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text("\(duration / 60) min")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("SecondaryTextColor"))
                }
            }
            
            if let duration = step.duration, duration > 0, !isCompleted {
                if viewModel.activeTimerStepId == step.id {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.formatTime(viewModel.remainingTime))
                            .font(.system(size: 44, weight: .bold, design: .monospaced))
                            .foregroundColor(Color("AccentColor"))
                        
                        HStack(spacing: 12) {
                            if viewModel.isTimerRunning {
                                Button("Pause") {
                                    viewModel.pauseTimer()
                                }
                                .buttonStyle(.bordered)
                            } else if viewModel.remainingTime > 0 {
                                Button("Resume") {
                                    viewModel.resumeTimer()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            
                            Button("Stop") {
                                viewModel.stopTimer()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                    .padding(.vertical, 6)
                } else if isActive {
                    Button {
                        viewModel.startTimer(for: step.id, duration: duration)
                    } label: {
                        HStack {
                            Image(systemName: "timer")
                            Text("Start Timer (\(duration / 60) min)")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(14)
                    }
                }
            }
            
            if isActive && !isCompleted {
                Button {
                    onComplete()
                } label: {
                    Text("Complete Step")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(Color("AccentColor"))
                        .cornerRadius(14)
                }
            }
        }
        .padding(isActive ? 20 : 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(borderColor, lineWidth: isActive ? 2.5 : 1)
        )
        .shadow(
            color: isActive ? Color("AccentColor").opacity(0.16) : .black.opacity(0.035),
            radius: isActive ? 16 : 10,
            x: 0,
            y: isActive ? 8 : 6
        )
        .opacity(isCompleted ? 0.78 : 1.0)
    }
    
    private var stepBadge: some View {
        ZStack {
            Circle()
                .fill(badgeBackground)
                .frame(width: isActive ? 38 : 30, height: isActive ? 38 : 30)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text(stepNumber(step.id))
                    .font(.system(size: isActive ? 17 : 14, weight: .bold))
                    .foregroundColor(isActive ? .white : Color("SecondaryTextColor"))
            }
        }
    }
    
    private var badgeBackground: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return Color("AccentColor")
        } else {
            return Color.gray.opacity(0.18)
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.green.opacity(0.055)
        } else if isActive {
            return Color("AccentColor").opacity(0.08)
        } else {
            return Color("CardColor")
        }
    }
    
    private var borderColor: Color {
        if isCompleted {
            return Color.green.opacity(0.22)
        } else if isActive {
            return Color("AccentColor")
        } else {
            return Color.gray.opacity(0.14)
        }
    }
    
    private func stepNumber(_ id: String) -> String {
        id.replacingOccurrences(of: "step", with: "")
    }
}

extension String {
    func capitalizedFirstLetter() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
