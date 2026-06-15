import SwiftUI

struct PauseFlowView: View {
    @EnvironmentObject private var appState: BYSAppState
    @Environment(\.dismiss) private var dismiss

    let trigger: PauseTrigger

    @State private var step = 0
    @State private var selectedAnswers: [String: Int] = [:]
    @State private var showIncorrectNotice = false
    @State private var session: PauseSession

    private let verse: Verse

    init(trigger: PauseTrigger) {
        self.trigger = trigger
        let selectedVerse = VerseLibrary.random()
        self.verse = selectedVerse
        _session = State(initialValue: PauseSession(trigger: trigger, verseID: selectedVerse.id, totalQuestions: selectedVerse.quiz.count))
    }

    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                progress

                TabView(selection: $step) {
                    verseStep.tag(0)
                    quizStep.tag(1)
                    decisionStep.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .interactiveDismissDisabled(trigger == .shield)
    }

    private var progress: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? BYSTheme.gold : Color.white.opacity(0.12))
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var verseStep: some View {
        VStack(spacing: 24) {
            BYSHeader(
                eyebrow: "Read",
                title: "Before you scroll…",
                subtitle: "Read the verse first. The check is short on purpose."
            )

            Spacer()

            BYSCard(padding: 24) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("“\(verse.text)”")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(BYSTheme.text)
                        .lineSpacing(6)

                    Text(verse.reference)
                        .font(.headline)
                        .foregroundStyle(BYSTheme.gold)
                }
            }

            Spacer()

            BYSPrimaryButton(title: "Start 3-question check", systemImage: "checklist") {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                    step = 1
                }
            }

            BYSSecondaryButton(title: "Stay Locked", systemImage: "checkmark.shield.fill") {
                finish(decision: .stayedLocked, minutes: nil)
            }
        }
        .padding(24)
    }

    private var quizStep: some View {
        VStack(spacing: 20) {
            BYSHeader(
                eyebrow: "Check",
                title: "Answer 3 quick questions.",
                subtitle: "This just confirms you slowed down and read the verse."
            )

            if showIncorrectNotice {
                Text("Read it once more. One or more answers were off.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BYSTheme.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(BYSTheme.red.opacity(0.12))
                    )
            }

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(verse.quiz.enumerated()), id: \.element.id) { index, question in
                        questionCard(index: index, question: question)
                    }
                }
                .padding(.vertical, 4)
            }

            BYSPrimaryButton(title: "Check Answers", systemImage: "checkmark.circle.fill") {
                checkAnswers()
            }
            .disabled(selectedAnswers.count < verse.quiz.count)
            .opacity(selectedAnswers.count < verse.quiz.count ? 0.5 : 1)

            BYSSecondaryButton(title: "Back to Verse", systemImage: "book.closed.fill") {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                    step = 0
                }
            }
        }
        .padding(24)
    }

    private func questionCard(index: Int, question: VerseQuizQuestion) -> some View {
        BYSCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Question \(index + 1)")
                    .font(.caption.bold())
                    .tracking(1.1)
                    .foregroundStyle(BYSTheme.gold)
                    .textCase(.uppercase)

                Text(question.prompt)
                    .font(.headline)
                    .foregroundStyle(BYSTheme.text)

                ForEach(Array(question.options.enumerated()), id: \.offset) { optionIndex, option in
                    Button {
                        selectedAnswers[question.id] = optionIndex
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: selectedAnswers[question.id] == optionIndex ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedAnswers[question.id] == optionIndex ? BYSTheme.gold : BYSTheme.textFaint)

                            Text(option)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BYSTheme.text)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedAnswers[question.id] == optionIndex ? BYSTheme.gold.opacity(0.13) : Color.white.opacity(0.055))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var decisionStep: some View {
        VStack(spacing: 22) {
            BYSHeader(
                eyebrow: "Choose",
                title: "You paused.",
                subtitle: "You read the verse and passed the check. Now choose intentionally."
            )

            BYSCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(session.correctAnswers)/\(session.totalQuestions) correct")
                        .font(.title.bold())
                        .foregroundStyle(BYSTheme.gold)

                    Text("That was enough to break autopilot.")
                        .foregroundStyle(BYSTheme.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            BYSPrimaryButton(title: "Unlock for 5 minutes", systemImage: "lock.open.fill") {
                finish(decision: .unlocked, minutes: 5)
            }

            Button {
                if appState.settings.isPremium {
                    finish(decision: .unlocked, minutes: 15)
                } else {
                    appState.isPaywallPresented = true
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Unlock for 15 minutes")
                        .fontWeight(.semibold)
                    Spacer()
                    if !appState.settings.isPremium {
                        Text("Premium")
                            .font(.caption.bold())
                            .foregroundStyle(BYSTheme.gold)
                    }
                }
                .padding(16)
                .foregroundStyle(BYSTheme.text)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(BYSTheme.border, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            BYSSecondaryButton(title: "Keep it locked", systemImage: "checkmark.shield.fill") {
                finish(decision: .stayedLocked, minutes: nil)
            }
        }
        .padding(24)
        .sheet(isPresented: $appState.isPaywallPresented) {
            PaywallView {
                appState.settings.isPremium = true
                appState.isPaywallPresented = false
            }
        }
    }

    private func checkAnswers() {
        let correct = verse.quiz.reduce(0) { count, question in
            guard let selected = selectedAnswers[question.id] else { return count }
            return count + (question.isCorrect(selected) ? 1 : 0)
        }

        session.correctAnswers = correct
        session.totalQuestions = verse.quiz.count

        if correct == verse.quiz.count {
            showIncorrectNotice = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                step = 2
            }
        } else {
            showIncorrectNotice = true
            selectedAnswers.removeAll()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                step = 0
            }
        }
    }

    private func finish(decision: PauseDecision, minutes: Int?) {
        session.completedAt = Date()
        session.decision = decision
        session.unlockedMinutes = minutes
        appState.savePauseSession(session)

        if let minutes {
            appState.unlockFor(minutes: minutes)
        } else {
            appState.applyShield()
        }

        dismiss()
    }
}

#Preview {
    PauseFlowView(trigger: .voluntary)
        .environmentObject(BYSAppState())
}
