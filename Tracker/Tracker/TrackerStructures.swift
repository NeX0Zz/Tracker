import UIKit

struct TrackerCategory {
    let header: String
    let trackerMass: [Tracker]
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let timetable: [WeekDay]?
    let pinned: Bool
    let colorIndex: Int
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}

enum WeekDay: Int, CaseIterable, Codable {
    
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var name: String {
        switch self {
        case .monday:
            return NSLocalizedString("weekDay.monday", comment: "")
        case .tuesday:
            return NSLocalizedString("weekDay.tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("weekDay.wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("weekDay.thursday", comment: "")
        case .friday:
            return NSLocalizedString("weekDay.friday", comment: "")
        case .saturday:
            return NSLocalizedString("weekDay.saturday", comment: "")
        case .sunday:
            return NSLocalizedString("weekDay.sunday", comment: "")
        }
    }
    
    var shortDaysName: String {
        switch self {
        case .monday:
            return NSLocalizedString("weekDay.m", comment: "")
        case .tuesday:
            return NSLocalizedString("weekDay.tue", comment: "")
        case .wednesday:
            return NSLocalizedString("weekDay.w", comment: "")
        case .thursday:
            return NSLocalizedString("weekDay.thu", comment: "")
        case .friday:
            return NSLocalizedString("weekDay.f", comment: "")
        case .saturday:
            return NSLocalizedString("weekDay.sat", comment: "")
        case .sunday:
            return NSLocalizedString("weekDay.su", comment: "")
        }
    }
}
