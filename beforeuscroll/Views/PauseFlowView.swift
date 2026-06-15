import SwiftUI

struct PauseFlowView: View {
    @EnvironmentObject private var appState: BYSAppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let trigger: PauseTrigger

    @State private var step = 0 // 0: Verse, 1: Questions, 2: Result
    @State private var questionQueue: [ShuffledQuizQuestion]
    @State private var completedCount = 0
    @State private var selectedOptionIndex: Int?
    @State private var typedAnswer = ""
    @State private var isAnswerLocked = false
    @State private var lastAnswerWasCorrect = false
    @State private var showFeedback = false
    @State private var rechargeResult: BYSFocusFlameStore.RechargeResult?
    @State private var startTime = Date()
    @State private var hasAppliedRecharge = false
    
    private let verse: Verse
    private let totalRequired = 5

    init(trigger: PauseTrigger) {
        self.trigger = trigger
        // In a real app we'd resolve goal from settings, for now assume doomscrolling/discipline
        let selectedVerse = VerseLibrary.verses[0] // Assume first for demo
        self.verse = selectedVerse
        
        let shuffled = selectedVerse.quiz.map { $0.shuffledForSession() }
        _questionQueue = State(initialValue: shuffled)
    }

    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()
            
            // Motion Background
            ParallaxEmberBackground()

            VStack(spacing: 0) {
                header
                
                BYSParallaxPager(step: step) { currentStep in
                    switch currentStep {
                    case 0:
                        verseRevealView
                    case 1:
                        questionView
                    default:
                        resultView
                    }
                }
            }
        }
        .interactiveDismissDisabled(trigger == .shield)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(BYSTheme.text)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
            .opacity(trigger == .shield ? 0 : 1)
            .disabled(trigger == .shield)

            Spacer()
            
            HStack(spacing: 8) {
                Text("\(completedCount) / \(totalRequired) remembered")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.gold)
                
                HStack(spacing: 4) {
                    ForEach(0..<totalRequired, id: \.self) { i in
                        Circle()
                            .fill(i < completedCount ? BYSTheme.gold : Color.white.opacity(0.12))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.white.opacity(0.06)))

            Spacer()
            
            // Placeholder for balance
            Circle().fill(Color.clear).frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private var verseRevealView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Read carefully.")
                    .font(.caption.weight(.black))
                    .foregroundStyle(appState.currentFlameTheme.primary)
                    .tracking(2)
                
                Text(verse.text)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(BYSTheme.text)
                    .lineSpacing(8)
                    .cardEntrance(delay: 0.2)
                
                Text(verse.reference)
                    .font(.headline.weight(.black))
                    .foregroundStyle(appState.currentFlameTheme.secondary)
                    .cardEntrance(delay: 0.5)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.8))
                    .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
            )
            .padding(.horizontal, 24)
            .parallaxTilt()

            Text("You'll be asked about the words, reference, and meaning.")
                .font(.subheadline)
                .foregroundStyle(BYSTheme.textFaint)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .cardEntrance(delay: 0.8)

            Spacer()

            BYSPrimaryButton(title: "Begin Questions", systemImage: "arrow.right") {
                withAnimation { step = 1 }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            if let question = currentQuestion {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(question.kind == .multipleChoice ? "Multiple Choice" : "Type your answer")
                            .font(.caption.weight(.black))
                            .foregroundStyle(appState.currentFlameTheme.primary)
                        
                        if question.isTrickQuestion {
                            Text("Attention Check")
                                .font(.system(size: 8, weight: .black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(BYSTheme.ember))
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    Text(question.prompt)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(BYSTheme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                if question.kind == .multipleChoice {
                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            multipleChoiceOption(option, index: index, question: question)
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    typedAnswerField(question: question)
                        .padding(.horizontal, 24)
                }

                if showFeedback {
                    feedbackPanel(question: question)
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                BYSPrimaryButton(title: isAnswerLocked ? "Continue" : "Check", systemImage: isAnswerLocked ? "arrow.right" : "checkmark.circle.fill") {
                    handleAction(question)
                }
                .disabled(!isAnswerLocked && (question.kind == .multipleChoice ? selectedOptionIndex == nil : typedAnswer.isEmpty))
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private func multipleChoiceOption(_ option: String, index: Int, question: ShuffledQuizQuestion) -> some View {
        let isSelected = selectedOptionIndex == index
        let isCorrect = question.correctIndex == index
        let showResult = isAnswerLocked
        
        return Button {
            if !isAnswerLocked {
                selectedOptionIndex = index
                BYSHaptics.lightTap()
            }
        } label: {
            HStack {
                Text(option)
                    .font(.headline.weight(.bold))
                Spacer()
                if showResult && isCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(BYSTheme.green)
                } else if showResult && isSelected && !isCorrect {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(BYSTheme.red)
                }
            }
            .padding(20)
            .foregroundStyle(BYSTheme.text)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(showResult && isCorrect ? BYSTheme.green.opacity(0.12) : showResult && isSelected ? BYSTheme.red.opacity(0.12) : isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(showResult && isCorrect ? BYSTheme.green : showResult && isSelected ? BYSTheme.red : isSelected ? BYSTheme.gold : BYSTheme.border, lineWidth: 2))
            )
        }
        .buttonStyle(.plain)
    }

    private func typedAnswerField(question: ShuffledQuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Type here...", text: $typedAnswer)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.06)))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(isAnswerLocked ? (lastAnswerWasCorrect ? BYSTheme.green : BYSTheme.red) : BYSTheme.border, lineWidth: 2))
                .disabled(isAnswerLocked)
                .submitLabel(.done)
                .onSubmit { handleAction(question) }
        }
    }

    private func feedbackPanel(question: ShuffledQuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lastAnswerWasCorrect ? "Correct!" : "Not quite.")
                .font(.headline.bold())
                .foregroundStyle(lastAnswerWasCorrect ? BYSTheme.green : BYSTheme.gold)
            
            if !lastAnswerWasCorrect, let explanation = question.explanation {
                Text(explanation)
                    .font(.subheadline)
                    .foregroundStyle(BYSTheme.textMuted)
            } else if !lastAnswerWasCorrect, let correct = question.correctAnswer {
                Text("The correct answer was: \(correct)")
                    .font(.subheadline)
                    .foregroundStyle(BYSTheme.textMuted)
            }
            
            if !lastAnswerWasCorrect {
                Text("You'll see this one again.")
                    .font(.caption.bold())
                    .foregroundStyle(BYSTheme.textFaint)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
    }

    private var resultView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            BYSFlameView(
                progress: appState.focusFlame.fillPercentage,
                isBurning: false,
                theme: appState.currentFlameTheme,
                showFace: true
            )
            .scaleEffect(1.4)
            
            VStack(spacing: 12) {
                Text("Scripture remembered.")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                
                if let result = rechargeResult {
                    Text("+\(result.addedSeconds / 60) min added to your Flame.")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(BYSTheme.gold)
                    
                    if result.missedSeconds > 0 {
                        Text("Cap reached (\(appState.focusFlame.maxFlameSeconds / 60) min max).")
                            .font(.caption.bold())
                            .foregroundStyle(BYSTheme.textFaint)
                    }
                }
            }
            
            Spacer()
            
            BYSPrimaryButton(title: "Done", systemImage: "checkmark.circle.fill") {
                dismiss()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var currentQuestion: ShuffledQuizQuestion? {
        questionQueue.first
    }

    private func handleAction(_ question: ShuffledQuizQuestion) {
        if !isAnswerLocked {
            checkAnswer(question)
        } else {
            advanceQuestion()
        }
    }

    private func checkAnswer(_ question: ShuffledQuizQuestion) {
        if question.kind == .multipleChoice {
            guard let index = selectedOptionIndex else { return }
            lastAnswerWasCorrect = question.isCorrect(index)
        } else {
            lastAnswerWasCorrect = question.isCorrect(typedAnswer)
        }
        
        isAnswerLocked = true
        withAnimation { showFeedback = true }
        
        if lastAnswerWasCorrect {
            BYSHaptics.success()
            completedCount += 1
        } else {
            BYSHaptics.warning()
        }
    }

    private func advanceQuestion() {
        let q = questionQueue.removeFirst()
        if !lastAnswerWasCorrect {
            questionQueue.append(q)
        }
        
        if completedCount >= totalRequired {
            completeFlow()
        } else {
            selectedOptionIndex = nil
            typedAnswer = ""
            isAnswerLocked = false
            showFeedback = false
        }
    }

    private func completeFlow() {
        if !hasAppliedRecharge {
            let duration = Int(Date().timeIntervalSince(startTime))
            rechargeResult = appState.rechargeFocusFlameFromScripture(durationSeconds: duration)
            hasAppliedRecharge = true
        }
        withAnimation(BYSMotion.successSpring) {
            step = 2
        }
    }
}

struct ParallaxEmberBackground: View {
    var body: some View {
        ZStack {
            RadialGradient(colors: [BYSTheme.ember.opacity(0.08), .clear], center: .center, startRadius: 10, endRadius: 400)
            
            // Decorative slow moving circles
            ForEach(0..<3) { i in
                Circle()
                    .fill(BYSTheme.gold.opacity(0.03))
                    .frame(width: 200 + CGFloat(i * 50))
                    .offset(x: i % 2 == 0 ? -100 : 100, y: i % 2 == 0 ? 200 : -200)
            }
        }
    }
}
