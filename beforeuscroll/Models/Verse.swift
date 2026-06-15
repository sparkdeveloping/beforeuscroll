import Foundation

struct Verse: Identifiable, Codable, Equatable {
    var id: String
    var reference: String
    var text: String
    var category: VerseCategory
    var quiz: [VerseQuizQuestion]
}

enum BYSQuestionKind: String, Codable, Equatable {
    case multipleChoice
    case typedText
}

struct VerseQuizQuestion: Identifiable, Codable, Equatable {
    var id: String
    var kind: BYSQuestionKind
    var prompt: String
    var options: [String] = []
    var correctIndex: Int?
    var correctAnswer: String?
    var acceptableAnswers: [String] = []
    var explanation: String?
    var isTrickQuestion: Bool = false

    func isCorrect(_ selectedIndex: Int) -> Bool {
        selectedIndex == correctIndex
    }
}

struct ShuffledQuizQuestion: Identifiable, Equatable {
    let id: String
    let kind: BYSQuestionKind
    let prompt: String
    let options: [String]
    let correctIndex: Int?
    let correctAnswer: String?
    let acceptableAnswers: [String]
    let explanation: String?
    let isTrickQuestion: Bool
    let originalQuestionID: String

    func isCorrect(_ selectedIndex: Int) -> Bool {
        guard kind == .multipleChoice else { return false }
        return selectedIndex == correctIndex
    }
    
    func isCorrect(_ text: String) -> Bool {
        guard kind == .typedText, let correct = correctAnswer else { return false }
        let normalizedInput = text.bys_normalized()
        let normalizedCorrect = correct.bys_normalized()
        
        if normalizedInput == normalizedCorrect { return true }
        
        for acceptable in acceptableAnswers {
            if normalizedInput == acceptable.bys_normalized() { return true }
        }
        
        // Simple typo tolerance for words longer than 5 chars
        if normalizedCorrect.count >= 5 {
            let distance = normalizedInput.levenshteinDistance(to: normalizedCorrect)
            if distance <= 1 { return true }
        }
        
        return false
    }
}

extension VerseQuizQuestion {
    func shuffledForSession() -> ShuffledQuizQuestion {
        let shuffledOptions: [String]
        let remappedCorrectIndex: Int?
        
        if kind == .multipleChoice {
            let indexedOptions = Array(options.enumerated()).shuffled()
            shuffledOptions = indexedOptions.map(\.element)
            remappedCorrectIndex = indexedOptions.firstIndex { originalIndex, _ in
                originalIndex == correctIndex
            }
        } else {
            shuffledOptions = []
            remappedCorrectIndex = nil
        }

        return ShuffledQuizQuestion(
            id: id,
            kind: kind,
            prompt: prompt,
            options: shuffledOptions,
            correctIndex: remappedCorrectIndex,
            correctAnswer: correctAnswer,
            acceptableAnswers: acceptableAnswers,
            explanation: explanation,
            isTrickQuestion: isTrickQuestion,
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

extension String {
    func bys_normalized() -> String {
        self.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .filter { !$0.isPunctuation }
    }
    
    func levenshteinDistance(to other: String) -> Int {
        let sCount = self.count
        let tCount = other.count
        
        if sCount == 0 { return tCount }
        if tCount == 0 { return sCount }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: tCount + 1), count: sCount + 1)
        
        for i in 0...sCount { matrix[i][0] = i }
        for j in 0...tCount { matrix[0][j] = j }
        
        let sChars = Array(self)
        let tChars = Array(other)
        
        for i in 1...sCount {
            for j in 1...tCount {
                if sChars[i-1] == tChars[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = Swift.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + 1)
                }
            }
        }
        
        return matrix[sCount][tCount]
    }
}
