import Foundation

struct PauseSession: Identifiable, Codable, Equatable {
    var id: UUID
    var startedAt: Date
    var completedAt: Date?
    var trigger: PauseTrigger
    var verseID: String
    var correctAnswers: Int
    var totalQuestions: Int
    var decision: PauseDecision?
    var unlockedMinutes: Int?

    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        trigger: PauseTrigger,
        verseID: String,
        correctAnswers: Int = 0,
        totalQuestions: Int = 3,
        decision: PauseDecision? = nil,
        unlockedMinutes: Int? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.trigger = trigger
        self.verseID = verseID
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.decision = decision
        self.unlockedMinutes = unlockedMinutes
    }

    var passedQuiz: Bool {
        correctAnswers >= totalQuestions
    }
}

enum PauseTrigger: String, Codable, Equatable {
    case voluntary
    case shield
    case schedule
}

enum PauseDecision: String, Codable, Equatable {
    case unlocked
    case stayedLocked
}
