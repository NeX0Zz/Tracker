import Foundation

enum Filters: CaseIterable {
    case allTrackers
    case trackersToday
    case completedTrackers
    case unCompletedTrackers
    
    var description: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("filters.cell.allTrackers.title", comment: "")
        case .trackersToday:
            return NSLocalizedString("filters.cell.trackersToday.title", comment: "")
        case .completedTrackers:
            return NSLocalizedString("filters.cell.completedTrackers.title", comment: "")
        case .unCompletedTrackers:
            return NSLocalizedString("filters.cell.uncompletedTrackers.title", comment: "")
        }
    }
}
