import UIKit

struct TrackerCategory {
    let header: String
    let trackerMass: [Tracker]
}

struct Tracker {
    let id = UUID()
    let name: String
    let color: UIColor
    let emoji: String
    let timetable: [WeekDay]?
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}

enum WeekDay: Int, CaseIterable {
    
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
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
}
