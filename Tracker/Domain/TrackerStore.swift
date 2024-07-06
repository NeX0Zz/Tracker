import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func store() -> Void
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: "TrackerCache"
        )
        try? controller.performFetch()
        return controller
    }()
    
    weak var delegate: TrackerStoreDelegate?

    var trackers: [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return try! objects.compactMap { try tracker(from: $0) }
    }
    
    override convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetchedResultsController.delegate = self
        context.automaticallyMergesChangesFromParent = false
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = UndoManager()
    }
    
    func addNewTracker(_ tracker: Tracker) {
        do {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.timetable = tracker.timetable?.map { $0.rawValue }
            try context.save()
        } catch {
            print("Error adding new tracker: \(error)")
            context.undoManager?.undo()
        }
    }
    
    private func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let emoji = trackerCoreData.emoji,
              let color = uiColorMarshalling.color(from: trackerCoreData.color!),
              let name = trackerCoreData.name,
              let timetable = trackerCoreData.timetable
        else {
            throw NSError(domain: "TrackerStore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid tracker data"])
        }
        return Tracker(id: id,
                       name: name,
                       color: color,
                       emoji: emoji,
                       timetable: timetable.compactMap({ WeekDay(rawValue: $0)}),
                       pinned: trackerCoreData.pinned,
                       colorIndex: Int(trackerCoreData.colorIndex))
    }
    
    func fetchTracker(with tracker: Tracker?) throws -> TrackerCoreData? {
        guard let tracker = tracker else { throw CustomError.coreDataError }
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
    
    func pinTracker(_ tracker: Tracker?, value: Bool) throws {
        let toPin = try fetchTracker(with: tracker)
        guard let toPin = toPin else { return }
        toPin.pinned = value
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker?) throws {
        let toDelete = try fetchTracker(with: tracker)
        guard let toDelete = toDelete else { return }
        context.delete(toDelete)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, oldTracker: Tracker?) throws {
        let updated = try fetchTracker(with: oldTracker)
        guard let updated = updated else { return }
        updated.name = tracker.name
        updated.colorIndex = Int16(tracker.colorIndex)
        updated.color = uiColorMarshalling.hexString(from: tracker.color)
        updated.emoji = tracker.emoji
        updated.timetable = tracker.timetable?.map {
            $0.rawValue
        }
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store()
    }
}
