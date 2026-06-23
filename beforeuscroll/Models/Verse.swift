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

enum BYSQuizQuestionType: String, Codable, Equatable {
    case reference
    case keyPhrase
    case meaning
    case application
}

struct BYSScriptureQuestionSession {
    static func build(for verse: Verse) -> [ShuffledQuizQuestion] {
        var result: [ShuffledQuizQuestion] = []
        let allQuestions = verse.quiz
        
        // Group by type
        let referenceQs = allQuestions.filter { $0.type == .reference && !$0.isTrickQuestion }
        let keyPhraseQs = allQuestions.filter { $0.type == .keyPhrase && !$0.isTrickQuestion }
        let meaningQs = allQuestions.filter { $0.type == .meaning && !$0.isTrickQuestion }
        let applicationQs = allQuestions.filter { $0.type == .application && !$0.isTrickQuestion }
        let trickQs = allQuestions.filter { $0.isTrickQuestion }
        
        // Ensure at least one of each required type if available
        if let q = referenceQs.shuffled().first { result.append(q.shuffledForSession()) }
        if let q = keyPhraseQs.shuffled().first { result.append(q.shuffledForSession()) }
        if let q = meaningQs.shuffled().first { result.append(q.shuffledForSession()) }
        if let q = applicationQs.shuffled().first { result.append(q.shuffledForSession()) }
        if let q = trickQs.shuffled().first { result.append(q.shuffledForSession()) }
        
        // If we still need more to reach 5, pick from the remaining pool
        let usedIDs = Set(result.map { $0.id })
        let remainingPool = allQuestions.filter { !usedIDs.contains($0.id) }
        
        let remainingNeeded = 5 - result.count
        if remainingNeeded > 0 {
            let extraQs = remainingPool.shuffled()
            for i in 0..<Swift.min(remainingNeeded, extraQs.count) {
                result.append(extraQs[i].shuffledForSession())
            }
        }
        
        var shuffledResult = result.shuffled()
        
        // Prevent same first question as last time if possible
        if let lastFirstID = BYSVerseRotationStore.lastFirstQuestionID(for: verse.id),
           shuffledResult.count > 1,
           shuffledResult.first?.id == lastFirstID {
            shuffledResult.shuffle()
        }
        
        if let firstID = shuffledResult.first?.id {
            BYSVerseRotationStore.setLastFirstQuestionID(firstID, for: verse.id)
        }
        
        return shuffledResult
    }
}

struct VerseQuizQuestion: Identifiable, Codable, Equatable {
    var id: String
    var kind: BYSQuestionKind
    var type: BYSQuizQuestionType
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
    let type: BYSQuizQuestionType
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
            type: type,
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
