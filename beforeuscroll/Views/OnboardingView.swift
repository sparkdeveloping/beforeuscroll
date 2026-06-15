import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: BYSAppState

    @State private var page = 0
    @State private var selectedGoal: ScrollGoal = .doomscrolling
    @State private var animateGlow = false

    private let pagesCount = 3

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topProgress

                TabView(selection: $page) {
                    welcomePage.tag(0)
                    howItWorksPage.tag(1)
                    goalPickerPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }

    private var background: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            RadialGradient(
                colors: [BYSTheme.gold.opacity(animateGlow ? 0.24 : 0.14), .clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 430
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [BYSTheme.purple.opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 80,
                endRadius: 460
            )
            .ignoresSafeArea()
        }
    }

    private var topProgress: some View {
        HStack(spacing: 8) {
            ForEach(0..<pagesCount, id: \.self) { index in
                Capsule()
                    .fill(index <= page ? BYSTheme.gold : Color.white.opacity(0.12))
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: page)
    }

    private var welcomePage: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 28)

            ZStack {
                Circle()
                    .fill(BYSTheme.warmGradient)
                    .frame(width: animateGlow ? 94 : 88, height: animateGlow ? 94 : 88)
                    .shadow(color: BYSTheme.gold.opacity(0.30), radius: 22, x: 0, y: 14)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(Color.black)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Welcome to BeforeUScroll")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.78)

                Text("Protect distracting apps with a Scripture pause.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BYSTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Spacer()

            BYSPrimaryButton(title: "Continue", systemImage: "arrow.right.circle.fill") {
                goToNextPage()
            }
        }
        .padding(24)
    }

    private var howItWorksPage: some View {
        VStack(spacing: 24) {
            BYSHeader(
                eyebrow: "How it works",
                title: "Scripture before scrolling.",
                subtitle: "Choose apps. Read one verse. Answer three questions. Then choose intentionally."
            )

            Spacer()

            VStack(spacing: 14) {
                flowCard(number: "1", title: "Choose apps", subtitle: "Pick the apps that pull you into scrolling.")
                flowCard(number: "2", title: "Read one verse", subtitle: "Pause with the current verse before opening them.")
                flowCard(number: "3", title: "Answer three questions", subtitle: "A quick check helps break autopilot.")
                flowCard(number: "4", title: "Choose intentionally", subtitle: "Unlock briefly or stay locked.")
            }

            Spacer()

            BYSPrimaryButton(title: "Continue", systemImage: "arrow.right") {
                goToNextPage()
            }
        }
        .padding(24)
    }

    private var goalPickerPage: some View {
        VStack(spacing: 20) {
            BYSHeader(
                eyebrow: "Your focus",
                title: "What do you want help with?",
                subtitle: "This chooses the kind of verses you’ll study first."
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(ScrollGoal.allCases) { goal in
                        goalButton(goal)
                    }
                }
                .padding(.vertical, 6)
            }

            BYSPrimaryButton(title: "Enter BeforeUScroll", systemImage: "arrow.right.circle.fill") {
                appState.completeOnboarding(goal: selectedGoal)
            }
        }
        .padding(24)
    }

    private func flowCard(number: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.headline.weight(.black))
                .foregroundStyle(Color.black)
                .frame(width: 42, height: 42)
                .background(Circle().fill(BYSTheme.gold))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(BYSTheme.text)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BYSTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.075))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(BYSTheme.border, lineWidth: 1)
                )
        )
    }

    private func goalButton(_ goal: ScrollGoal) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                selectedGoal = goal
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selectedGoal == goal ? BYSTheme.gold : BYSTheme.textFaint)

                VStack(alignment: .leading, spacing: 5) {
                    Text(goal.title)
                        .font(.headline.bold())
                        .foregroundStyle(BYSTheme.text)

                    Text(goal.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(BYSTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(selectedGoal == goal ? BYSTheme.gold.opacity(0.14) : Color.white.opacity(0.055))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(selectedGoal == goal ? BYSTheme.gold.opacity(0.55) : BYSTheme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func goToNextPage() {
        withAnimation(.spring(response: 0.46, dampingFraction: 0.84)) {
            page = min(page + 1, pagesCount - 1)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(BYSAppState())
}
