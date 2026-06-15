import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

enum BYSSelectionStore {
    private static let selectionKey = "bys.familyActivitySelection"
    private static let selectedCountKey = "bys.selectedAppsCount"

    #if canImport(FamilyControls)
    static func save(_ selection: FamilyActivitySelection) {
        do {
            let data = try JSONEncoder().encode(selection)
            BYSAppGroup.defaults.set(data, forKey: selectionKey)
            BYSAppGroup.defaults.set(selectionTotalCount(selection), forKey: selectedCountKey)
        } catch {
            print("Failed to save FamilyActivitySelection: \(error)")
        }
    }

    static func load() -> FamilyActivitySelection {
        guard let data = BYSAppGroup.defaults.data(forKey: selectionKey) else {
            return FamilyActivitySelection()
        }

        do {
            return try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load FamilyActivitySelection: \(error)")
            return FamilyActivitySelection()
        }
    }

    static func selectionTotalCount(_ selection: FamilyActivitySelection) -> Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }
    #endif

    static func saveSelectedCount(_ count: Int) {
        BYSAppGroup.defaults.set(count, forKey: selectedCountKey)
    }

    static func loadSelectedCount() -> Int {
        BYSAppGroup.defaults.integer(forKey: selectedCountKey)
    }
}
