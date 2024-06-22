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
        return Tracker(id: id, name: name, color: color, emoji: emoji, timetable: timetable.compactMap { WeekDay(rawValue: $0) })
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store()
    }
}

