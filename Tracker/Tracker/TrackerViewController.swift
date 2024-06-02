import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    var selectedDate: Int?
    var currentDate = Date()
    
    // MARK: - Private Properties
    
    private var trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
    private var filterText: String?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    private lazy var imageView:UIImageView = {
        let image = UIImage(named: "dizzy")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var emptyImageView:UIImageView = {
        let image = UIImage(named: "dizzy")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = UIFont(name: "SF Pro", size: 12)
        return label
    }()
    
    private lazy var setSearchBar: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Поиск"
        search.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.layer.cornerRadius = 0.3
        datePicker.clipsToBounds = true
        return datePicker
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - Overrides Methods
    
    override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem(title: "Трекеры")
        let add = UIBarButtonItem(barButtonSystemItem:.add, target: self, action: #selector(addTapped))
        let datePickerBarItem = UIBarButtonItem(customView: datePicker)
        add.tintColor = .black
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = add
        navigationItem.rightBarButtonItem = datePickerBarItem
        navigationItem.searchController = setSearchBar
        return navigationItem
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        selectCurrentDay()
        view.backgroundColor = .systemBackground
        setSearchBar.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HeaderSectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderSectionView.id)
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        trackers = trackerStore.trackers
        completedTrackers = trackerRecordStore.trackerRecords
        let category = TrackerCategory(header: "В школе", trackerMass: trackers)
        categories.append(category)
        show()
        filterTrackers()
    }
    
    override func loadView(){
        super.loadView()
        setup()
    }
    
    // MARK: - Private Methods
    
    @objc private func addTapped(){
        let addTracker = AddTrackerViewController()
        addTracker.trackerViewController = self
        present(addTracker, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectCurrentDay()
 //       getCurrentWeekday()
        filterTrackers()
    }
    
    func filterTrackers() {
        visibleCategories = filterCategories()
        show()
        label.text = "Ничего не найдено"
        imageView.image = UIImage(named: "empty")
        collectionView.reloadData()
    }
    
//    private func getCurrentWeekday() -> Day {
//        let calendar = Calendar.current
//        let weekday = calendar.component(.weekday, from: datePicker.date)
//        let currentWeekday = Day.getDayFromNumber(number: weekday)
//        print(currentWeekday)
//        return currentWeekday
//    }
    
    func selectCurrentDay() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        selectedDate = filterWeekday
    }
    
    private func setup(){
        [collectionView, imageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func getDate() -> WeekDay {
        selectCurrentDay()
        let sellect = selectedDate
        switch sellect {
        case 2:
            return WeekDay.monday
        case 3:
            return WeekDay.tuesday
        case 4:
            return WeekDay.wednesday
        case 5:
            return WeekDay.thursday
        case 6:
            return WeekDay.friday
        case 7:
            return WeekDay.saturday
        case 1:
            return WeekDay.sunday
        default:
            return WeekDay.sunday
        }
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSameDay
    }
    
    private func show(){
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
            imageView.isHidden = true
            label.isHidden = true
        }
    }
    
    private func filterCategories() -> [TrackerCategory] {
        return categories.map { category in
            let filteredTrackers = category.trackerMass.filter { satisfiesFilters(tracker: $0) }
            return TrackerCategory(header: category.header, trackerMass: filteredTrackers)
        }.filter {!$0.trackerMass.isEmpty }
    }
    
    private func satisfiesFilters(tracker: Tracker) -> Bool {
        let scheduleContains = tracker.timetable?.contains { day in
            guard let currentDay = selectedDate else {
                return true
            }
            return day.rawValue == currentDay
        } ?? false
        let titleContains = tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
        return scheduleContains && titleContains
    }
}

// MARK: - UISearchBarDelegate

extension TrackerViewController: UISearchBarDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let searchBar = textField as? UISearchBar,
           let text = searchBar.text {
            self.filterText = text
            filterTrackers()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterText = searchBar.text
        filterTrackers()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackerMass.count
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackerCollectionViewCell
        cell.delegate = self
        cell.prepareForReuse()
        let tracker = visibleCategories[indexPath.section].trackerMass[indexPath.row]
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configure(tracker: tracker, completedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSectionView.id, for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }
        guard indexPath.section < visibleCategories.count else {
            return header
        }
        let headerText = visibleCategories[indexPath.section].header
        header.headerText = headerText
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: (collectionView.bounds.width / 2 - 5) * 0.88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 47)
    }
}

// MARK: - TrackerCellDelegate

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            let trackerRecord = TrackerRecord(id: id, date: selectedDate)
            try?
            trackerRecordStore.addNewTrackerRecord(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
        } else {
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let toRemove = completedTrackers.first {
            isTrackerRecord(trackerRecord: $0, id: id)
        }
        try! self.trackerRecordStore.removeTrackerRecord(toRemove)
    }
}

// MARK: - TrackersActions

extension TrackerViewController: TrackersActions {
    func appendTracker(tracker: Tracker) {
        trackerStore.addNewTracker(tracker)
        categories = categories.map { category in
            var updatedTrackers = category.trackerMass
            updatedTrackers.append(tracker)
            return TrackerCategory(header: category.header, trackerMass: updatedTrackers)
        }
        filterTrackers()
    }
    
    func reload() {
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func store() {
        trackers = trackerStore.trackers
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func storeRecord() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}


