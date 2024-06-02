import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeRecord()
}

final class TrackerRecordStore: NSObject {
    private var context: NSManagedObjectContext
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.id , ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let records = try? objects.map({ try self.record(from: $0)})
        else { return [] }
        return records
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
        super.init()
        fetchedResultsController.delegate = self
    }
    
    private func record(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id,
              let date = trackerRecordCoreData.date
        else { throw CustomError.coreDataError }
        return TrackerRecord(id: id, date: date)
    }
    
   private func fetchTrackerRecord(with trackerRecord: TrackerRecord?) throws -> TrackerRecordCoreData? {
        guard let trackerRecord else { throw CustomError.coreDataError }
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate =  NSPredicate(format: "id == %@ AND date == %@", trackerRecord.id as CVarArg, trackerRecord.date as NSDate)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        try context.save()
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord?) throws {
        guard let toDelete = try self.fetchTrackerRecord(with: trackerRecord)
        else { throw CustomError.coreDataError }
        context.delete(toDelete)
        try context.save()
    }
}

enum CustomError: Error {
    case coreDataError
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeRecord()
    }
}
