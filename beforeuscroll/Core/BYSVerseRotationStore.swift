import Foundation

struct BYSVerseRotationState: Codable, Equatable {
    var queuesByCategory: [String: [String]] = [:] // VerseCategory.rawValue: [VerseID]
    var indicesByCategory: [String: Int] = [:] // VerseCategory.rawValue: CurrentIndex
    var lastFirstQuestionIDByVerse: [String: String] = [:] // VerseID: QuestionID
}

enum BYSVerseRotationStore {
    private static let stateKey = "bys.verseRotation.state"
    
    static func currentVerse(for category: VerseCategory) -> Verse {
        var state = loadState()
        let categoryKey = category.rawValue
        
        let queue = getOrInitializeQueue(for: category, in: &state)
        var index = state.indicesByCategory[categoryKey] ?? 0
        
        if index >= queue.count {
            state.indicesByCategory[categoryKey] = 0
            saveState(state)
            index = 0
        }
        
        let verseID = queue[index]
        return VerseLibrary.verses.first(where: { $0.id == verseID }) ?? VerseLibrary.verses[0]
    }

    static func ensureQueueExists(for goal: ScrollGoal) {
        var state = loadState()
        _ = getOrInitializeQueue(for: VerseLibrary.category(for: goal), in: &state)
    }
    
    static func lastFirstQuestionID(for verseID: String) -> String? {
        let state = loadState()
        return state.lastFirstQuestionIDByVerse[verseID]
    }
    
    static func setLastFirstQuestionID(_ questionID: String, for verseID: String) {
        var state = loadState()
        state.lastFirstQuestionIDByVerse[verseID] = questionID
        saveState(state)
    }
    
    static func advance(for category: VerseCategory) {
        var state = loadState()
        let categoryKey = category.rawValue
        let queue = getOrInitializeQueue(for: category, in: &state)
        let currentIndex = state.indicesByCategory[categoryKey] ?? 0
        
        let nextIndex = currentIndex + 1
        
        if nextIndex >= queue.count {
            // Reshuffle and restart
            state.queuesByCategory[categoryKey] = queue.shuffled()
            state.indicesByCategory[categoryKey] = 0
            
            // Avoid showing the same verse twice in a row if possible
            if state.queuesByCategory[categoryKey]?.first == queue.last && queue.count > 1 {
                state.queuesByCategory[categoryKey]?.shuffle()
            }
        } else {
            state.indicesByCategory[categoryKey] = nextIndex
        }
        
        saveState(state)
    }
    
    private static func getOrInitializeQueue(for category: VerseCategory, in state: inout BYSVerseRotationState) -> [String] {
        let categoryKey = category.rawValue
        if let queue = state.queuesByCategory[categoryKey], !queue.isEmpty {
            return queue
        }
        
        let verses = VerseLibrary.verses(for: category)
        let ids = verses.map { $0.id }.shuffled()
        state.queuesByCategory[categoryKey] = ids
        state.indicesByCategory[categoryKey] = 0
        saveState(state)
        return ids
    }
    
    private static func loadState() -> BYSVerseRotationState {
        LocalStore.load(BYSVerseRotationState.self, for: .verseRotation) ?? BYSVerseRotationState()
    }
    
    private static func saveState(_ state: BYSVerseRotationState) {
        LocalStore.save(state, for: .verseRotation)
    }
}
