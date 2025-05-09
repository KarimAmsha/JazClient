import SwiftUI

// Enum steps for registration
enum RegistrationStep: Int {
    case role, personalInfo, workInfo, identity, confirmPhone
}

struct RegistrationFlowView: View {
    @State private var selectedRole: UserRole? = .provider
    @State private var step: RegistrationStep = .role
    @State private var showSpecialtyPopup = false
    @State private var showPrivacySheet = false
    @State private var showSuccessPopup = false
    @State private var agreedToPrivacy = false
    @EnvironmentObject var appState: AppState
    var steps: [RegistrationStep] {
        if selectedRole == .client {
            return [.role, .personalInfo, .confirmPhone]
        } else {
            return [.role, .personalInfo, .workInfo, .identity, .confirmPhone]
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                StepTabsView(currentStep: step, steps: steps)
                    .padding(.top)

                Spacer()

                ZStack {
                    switch step {
                    case .role:
                        RegistrationRoleView(selectedRole: $selectedRole)
                    case .personalInfo:
                        RegistrationPersonalInfoView()
                    case .workInfo:
                        RegistrationWorkInfoView(showSpecialtyPopup: $showSpecialtyPopup)
                    case .identity:
                        RegistrationIdentityView()
                    case .confirmPhone:
                        ConfirmPhoneView(onComplete: {
                            showSuccessPopup = true
                        })
                    }
                }
                .animation(.easeInOut, value: step)
                .transition(.slide)

                Spacer()

                HStack(spacing: 12) {
                    if step != .role {
                        SecondaryActionButton(title: "رجوع") {
                            goToPrevious()
                        }
                    }
                    PrimaryActionButton(title: step == .confirmPhone ? "إتمام الطلب" : "التالي") {
                        if step == .confirmPhone {
                            if agreedToPrivacy {
                                showSuccessPopup = true
                            } else {
                                showPrivacySheet = true
                            }
                        } else {
                            goToNext()
                        }
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .background(Color.background())
            .environment(\.layoutDirection, .rightToLeft)
            .popup(isPresented: $showSpecialtyPopup) {
                SpecialtySelectionPopup(isPresented: $showSpecialtyPopup)
            } customize: {
                $0
                    .type(.default)
                    .position(.center)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .closeOnTap(true)
                    .backgroundColor(Color.black.opacity(0.5))
                    .useKeyboardSafeArea(true)
            }
            .popup(isPresented: $showSuccessPopup) {
                SuccessSubmissionView(isPresented: $showSuccessPopup)
                    .environmentObject(appState)
            } customize: {
                $0
                    .type(.default)
                    .position(.bottom)
                    .closeOnTapOutside(false)
                    .backgroundColor(Color.black.opacity(0.4))
                    .useKeyboardSafeArea(true)
            }
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicyAgreementView(showSheet: $showPrivacySheet) {
                agreedToPrivacy = true
                showSuccessPopup = true
            }
        }
    }

    private func goToNext() {
        if let currentIndex = steps.firstIndex(of: step),
           currentIndex + 1 < steps.count {
            step = steps[currentIndex + 1]
        }
    }

    private func goToPrevious() {
        if let currentIndex = steps.firstIndex(of: step),
           currentIndex > 0 {
            step = steps[currentIndex - 1]
        }
    }
}

struct StepTabsView: View {
    var currentStep: RegistrationStep
    var steps: [RegistrationStep]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(steps, id: \.self) { step in
                Rectangle()
                    .fill(color(for: step))
                    .frame(height: 4)
            }
        }
    }

    private func color(for step: RegistrationStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return Color(hex: "F8B22A")
        } else if step == currentStep {
            return Color.primary()
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}


#Preview {
    RegistrationFlowView()
}
