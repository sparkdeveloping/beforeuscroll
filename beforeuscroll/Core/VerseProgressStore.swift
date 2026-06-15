import Foundation

enum VerseProgressStore {
    private static let calendar = Calendar.current

    static func currentVerseOfStudy(for goal: ScrollGoal, date: Date = Date()) -> Verse {
        var state = loadState()
        let today = calendar.startOfDay(for: date)
        let goalKey = goal.rawValue
        let category = VerseLibrary.category(for: goal)
        let candidates = VerseLibrary.verses(for: category)

        guard !candidates.isEmpty else {
            return VerseLibrary.verse(for: goal)
        }

        if let storedDate = state.dailyVerseDateByGoal[goalKey],
           calendar.isDate(storedDate, inSameDayAs: today),
           let storedID = state.dailyVerseIDByGoal[goalKey],
           let storedVerse = candidates.first(where: { $0.id == storedID }) {
            return storedVerse
        }

        let selected = selectDailyVerse(from: candidates, goalKey: goalKey, today: today, state: state)
        state.dailyVerseDateByGoal[goalKey] = today
        state.dailyVerseIDByGoal[goalKey] = selected.id
        state.selectedGoalRawValue = goal.rawValue
        saveState(state)
        return selected
    }

    static func markCompleted(verseID: String, for goal: ScrollGoal, date: Date = Date()) {
        var state = loadState()
        let goalKey = goal.rawValue
        var completed = Set(state.completedVerseIDsByGoal[goalKey] ?? [])
        completed.insert(verseID)
        state.completedVerseIDsByGoal[goalKey] = Array(completed)
        state.lastCompletedVerseIDByGoal[goalKey] = verseID
        state.lastCompletionDate = date
        state.selectedGoalRawValue = goal.rawValue
        saveState(state)
    }

    private static func selectDailyVerse(from candidates: [Verse], goalKey: String, today: Date, state: VerseProgressState) -> Verse {
        let start = calendar.startOfDay(for: state.curriculumStartDate)
        let dayOffset = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        var index = abs(dayOffset) % candidates.count
        var selected = candidates[index]

        if candidates.count > 1,
           selected.id == state.lastCompletedVerseIDByGoal[goalKey] {
            index = (index + 1) % candidates.count
            selected = candidates[index]
        }

        return selected
    }

    private static func loadState() -> VerseProgressState {
        LocalStore.load(VerseProgressState.self, for: .verseProgress) ?? VerseProgressState(curriculumStartDate: calendar.startOfDay(for: Date()))
    }

    private static func saveState(_ state: VerseProgressState) {
        LocalStore.save(state, for: .verseProgress)
    }
}

struct VerseProgressState: Codable, Equatable {
    var curriculumStartDate: Date
    var selectedGoalRawValue: String?
    var dailyVerseDateByGoal: [String: Date]
    var dailyVerseIDByGoal: [String: String]
    var completedVerseIDsByGoal: [String: [String]]
    var lastCompletedVerseIDByGoal: [String: String]
    var lastCompletionDate: Date?

    init(
        curriculumStartDate: Date,
        selectedGoalRawValue: String? = nil,
        dailyVerseDateByGoal: [String: Date] = [:],
        dailyVerseIDByGoal: [String: String] = [:],
        completedVerseIDsByGoal: [String: [String]] = [:],
        lastCompletedVerseIDByGoal: [String: String] = [:],
        lastCompletionDate: Date? = nil
    ) {
        self.curriculumStartDate = curriculumStartDate
        self.selectedGoalRawValue = selectedGoalRawValue
        self.dailyVerseDateByGoal = dailyVerseDateByGoal
        self.dailyVerseIDByGoal = dailyVerseIDByGoal
        self.completedVerseIDsByGoal = completedVerseIDsByGoal
        self.lastCompletedVerseIDByGoal = lastCompletedVerseIDByGoal
        self.lastCompletionDate = lastCompletionDate
    }
}
