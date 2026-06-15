import Foundation

struct Verse: Identifiable, Codable, Equatable {
    var id: String
    var reference: String
    var text: String
    var category: VerseCategory
    var quiz: [VerseQuizQuestion]
}

struct VerseQuizQuestion: Identifiable, Codable, Equatable {
    var id: String
    var prompt: String
    var options: [String]
    var correctIndex: Int

    func isCorrect(_ selectedIndex: Int) -> Bool {
        selectedIndex == correctIndex
    }
}

struct ShuffledQuizQuestion: Identifiable, Equatable {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let originalQuestionID: String

    func isCorrect(_ selectedIndex: Int) -> Bool {
        selectedIndex == correctIndex
    }
}

extension VerseQuizQuestion {
    func shuffledForSession() -> ShuffledQuizQuestion {
        let shuffledOptions = Array(options.enumerated()).shuffled()
        let remappedCorrectIndex = shuffledOptions.firstIndex { originalIndex, _ in
            originalIndex == correctIndex
        } ?? correctIndex

        return ShuffledQuizQuestion(
            id: id,
            prompt: prompt,
            options: shuffledOptions.map(\.element),
            correctIndex: remappedCorrectIndex,
            originalQuestionID: id
        )
    }
}

enum VerseCategory: String, CaseIterable, Codable, Identifiable {
    case discipline
    case purity
    case focus
    case anxiety
    case wisdom
    case redeemingTime
    case renewedMind
    case contentment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .discipline: return "Discipline"
        case .purity: return "Purity"
        case .focus: return "Focus"
        case .anxiety: return "Anxiety"
        case .wisdom: return "Wisdom"
        case .redeemingTime: return "Redeeming Time"
        case .renewedMind: return "Renewed Mind"
        case .contentment: return "Contentment"
        }
    }
}
