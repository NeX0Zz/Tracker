import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeCategory() -> Void
}

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: "TrackerCategoryCache")
        try? controller.performFetch()
        return controller
    }()
    
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerStore: TrackerStore
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var trackerCategories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return try! objects.compactMap { try trackerCategory(from: $0) }
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
        fetchedResultsController.delegate = self
    }

    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.header = category.header
        trackerCategoryCoreData.trackers = category.trackerMass.compactMap {
            $0.id
        }
        try context.save()
    }
    
    func addTrackerToCategory(to header: TrackerCategory?, tracker: Tracker) throws {
        guard let fromDb = try self.fetchTrackerCategory(with: header) else {
            fatalError()
        }
        fromDb.trackers = trackerCategories.first {
            $0.header == fromDb.header
        }?.trackerMass.map { $0.id }
        fromDb.trackers?.append(tracker.id)
        try context.save()
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = trackerCategoryCoreData.header,
              let trackers = trackerCategoryCoreData.trackers
        else {
            throw TrackerError.defaultError
        }
        return TrackerCategory(header: header, trackerMass: trackerStore
            .trackers
            .filter { trackers.contains($0.id) })
    }
    
    func fetchTrackerCategory(with header: TrackerCategory?) throws -> TrackerCategoryCoreData? {
        guard let header = header else { fatalError() }
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "header == %@",
            header.header as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
}

enum TrackerError: Error {
    case defaultError
    
}

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTracker
    case decodingErrorInvalidFetchTitle
    case decodingErrorInvalid
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeCategory()
    }
}


