import CoreData

final class CategoryViewModel {
        
    static let shared = CategoryViewModel()
    private var categoryStore = TrackerCategoryStore.shared
    private (set) var categories: [TrackerCategory] = []
    
    @Observable
    private (set) var selectedCategory: TrackerCategory?
    
    init() {
        categoryStore.delegate = self
        self.categories = categoryStore.trackerCategories
    }
    
    func addCategory(_ toAdd: String) {
        try! self.categoryStore.addNewCategory(TrackerCategory(header: toAdd, trackerMass: []))
    }
    
    func addTrackerToCategory(to header: TrackerCategory?, tracker: Tracker) {
        try! self.categoryStore.addTrackerToCategory(to: header, tracker: tracker)
    }
    
    func selectCategory(_ at: Int) {
        self.selectedCategory = self.categories[at]
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeCategory() {
        self.categories = categoryStore.trackerCategories
    }
}

