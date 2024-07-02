import UIKit

final class TrackerViewController: UIViewController {
    
    private var trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    private(set) var categoryViewModel: CategoryViewModel = CategoryViewModel.shared
    private let analytics = Analytics.shared
    private var trackers: [Tracker] = []
    private var pinnedTrackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    
    var completedTrackers: [TrackerRecord] = []
    
    private var selectedDate: Int?
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
    
    private lazy var filtersButton: UIButton = {
        let filtersButton = UIButton()
        filtersButton.layer.cornerRadius = 16
        filtersButton.backgroundColor = .bluee
        filtersButton.setTitle(NSLocalizedString("filter.title", comment: ""), for: .normal)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return filtersButton
    }()
    
    private lazy var emptyImageView:UIImageView = {
        let image = UIImage(named: "dizzy")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не "
        label.font = UIFont(name: "SF Pro", size: 12)
        return label
    }()
    
    private lazy var setSearchBar: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = NSLocalizedString("searchBar.placholder", comment: "")
        search.searchBar.setValue(NSLocalizedString("button.cancel.title", comment: ""), forKey: "cancelButtonText")
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
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
    
    private lazy var addTrackerButton: UIButton = {
        let addTrackerButton = UIButton()
        let originalImage = UIImage(named: "Adda")!
        let tintedImage = originalImage.withRenderingMode(.alwaysTemplate)
        addTrackerButton.setImage(tintedImage, for: .normal)
        addTrackerButton.tintColor = .black
        addTrackerButton.addTarget(self, action: #selector(didTapAddTracker), for: .touchUpInside)
        return addTrackerButton
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            
            addTrackerButton.tintColor = .white
        } else {
            addTrackerButton.tintColor = .black
        }
    }
    
    override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem(title: NSLocalizedString("app.title", comment: ""))
        let datePickerBarItem = UIBarButtonItem(customView: datePicker)
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = datePickerBarItem
        navigationItem.searchController = setSearchBar
        return navigationItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchBar.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        selectCurrentDay()
        view.backgroundColor = .systemBackground
        setup()
        showVisibleViews()
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        trackers = trackerStore.trackers.filter { !$0.pinned }
        pinnedTrackers = trackerStore.trackers.filter { $0.pinned }
        completedTrackers = trackerRecordStore.trackerRecords
        categories = categoryViewModel.categories
        categories.insert(TrackerCategory(header: "Закрепленные", trackerMass: pinnedTrackers), at: 0)
        filterVisibleCategories()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(HeaderSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderSectionView.id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        
    }
    
    private func setup(){
        [collectionView, imageView, label,filtersButton].forEach {
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
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filtersButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.report("open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.report("close", params: ["screen": "Main"])
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
    
    @objc private func didTapAddTracker() {
        analytics.report("click", params: ["screen": "Main", "item": "add_track"])
        let addTracker = AddTrackerViewController()
        addTracker.trackerViewController = self
        present(addTracker, animated: true, completion: nil)
    }
    
    @objc private func pickerChanged() {
        selectCurrentDay()
        filterTrackers(forToday: true)
    }
    
    @objc private func filtersButtonTapped() {
        analytics.report("click", params: ["screen": "Main", "item": "filter"])
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        present(filterViewController, animated: true)
    }
    
    private func selectCurrentDay() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        self.selectedDate = filterWeekday
    }
    
    private func filterTrackers(forToday: Bool = false) {
        filterVisibleCategories(forToday: forToday)
        showVisibleViews()
        collectionView.reloadData()
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
    
    private func filterVisibleCategories(forToday: Bool = false) {
        visibleCategories = categories.map { category in
            if category.header == "Закрепленные" {
                return TrackerCategory(header: category.header, trackerMass: pinnedTrackers.filter { tracker in
                    return tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                })
            } else {
                return TrackerCategory(header: category.header, trackerMass: trackers.filter { tracker in
                    let categoriesContains = category.trackerMass.contains { $0.id == tracker.id }
                    let pinnedContains = pinnedTrackers.contains{ $0.id == tracker.id }
                    let scheduleContains = forToday ? (tracker.timetable?.contains { day in
                        guard let currentDay = self.selectedDate else {
                            return true
                        }
                        return day.rawValue == currentDay
                    } ?? false) : true
                    
                    
                    let titleContains = tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                    return scheduleContains && titleContains && categoriesContains && !pinnedContains
                })
            }
        }
        .filter { category in
            !category.trackerMass.isEmpty
        }
        showVisibleViews()
    }
}


// MARK: - TrackerStoreDelegate

extension TrackerViewController: FilterViewControllerDelegate {
    func allTrackers() {
        trackers = trackerStore.trackers
        filterVisibleCategories(forToday: false)
        collectionView.reloadData()
    }
    
    func trackersToday() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        trackers = trackerStore.trackers.filter {
            $0.timetable?.contains(where: { $0.rawValue ==  weekday}) ?? false
        }
        
        filterVisibleCategories()
        collectionView.reloadData()
    }
    
    func completedTrackersToday() {
        analytics.report("track", params: ["event": "tap", "screen": "Main"])
        trackers = trackerStore.trackers.filter { isTrackerCompletedToday(id: $0.id) }
        
        filterVisibleCategories()
        collectionView.reloadData()
    }
    
    func unCompletedTrackersToday() {
        analytics.report("track", params: ["event": "tap", "screen": "Main"])
        trackers = trackerStore.trackers.filter { !isTrackerCompletedToday(id: $0.id) }
        filterVisibleCategories()
        collectionView.reloadData()
    }
}

// MARK: - TrackerStoreDelegate

extension TrackerViewController: TrackerStoreDelegate {
    func store() {
        let fromDb = trackerStore.trackers
        trackers = fromDb.filter { !$0.pinned }
        pinnedTrackers = fromDb.filter { $0.pinned }
        filterVisibleCategories()
        collectionView.reloadData()
    }
}

// MARK: - TrackersActions

extension TrackerViewController: TrackersActions {
    func appendTracker(tracker: Tracker, category: String?) {
        guard let category = category else { return }
        self.trackerStore.addNewTracker(tracker)
        let foundCategory = self.categories.first { ctgry in
            ctgry.header == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { ctgry in
                if (ctgry.header == category) {
                    var updatedTrackers = ctgry.trackerMass
                    updatedTrackers.append(tracker)
                    return TrackerCategory(header: ctgry.header, trackerMass: updatedTrackers)
                } else {
                    return TrackerCategory(header: ctgry.header, trackerMass: ctgry.trackerMass)
                }
            }
        } else {
            self.categories.append(TrackerCategory(header: category, trackerMass: [tracker]))
        }
        filterTrackers()
    }
    
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?) {
        guard let category = category, let oldTracker = oldTracker else { return }
        try? self.trackerStore.updateTracker(tracker, oldTracker: oldTracker)
        let foundCategory = self.categories.first { ctgry in
            ctgry.header == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { ctgry in
                if (ctgry.header == category) {
                    var updatedTrackers = ctgry.trackerMass
                    updatedTrackers.append(tracker)
                    return TrackerCategory(header: ctgry.header, trackerMass: updatedTrackers)
                } else {
                    return TrackerCategory(header: ctgry.header, trackerMass: ctgry.trackerMass)
                }
            }
        } else {
            self.categories.append(TrackerCategory(header: category, trackerMass: [tracker]))
        }
        filterTrackers()
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
    
    func showVisibleViews() {
        
        show()
        if trackerStore.trackers.count == 0 || visibleCategories.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
        collectionView.reloadData()
    }
    
    func showSearchViews() {
        collectionView.isHidden = visibleCategories.isEmpty
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackerMass.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        let tracker = visibleCategories[indexPath.section].trackerMass[indexPath.row]
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        cell.configure(tracker: tracker, completedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)
        cell.backgroundColor = .clear
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
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSameDay
    }
}

// MARK: - TrackerCellDelegate

extension TrackerViewController: TrackerRecordStoreDelegate {
    func storeRecord() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            let trackerRecord = TrackerRecord(id: id, date: selectedDate)
            try?
            self.trackerRecordStore.addNewTrackerRecord(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
            analytics.report("click", params: ["screen": "Main", "item": "complete"])
        } else {
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let toRemove = completedTrackers.first {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
        try? self.trackerRecordStore.removeTrackerRecord(toRemove)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: (collectionView.bounds.width / 2 - 5) * 0.88)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 47)
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = self.visibleCategories[indexPath.section].trackerMass[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] () -> UIViewController? in
            guard let self = self else { return nil }
            
            let previewVC = PreviewViewController()
            let cellSize = CGSize(width: self.collectionView.bounds.width / 2 - 5, height: (self.collectionView.bounds.width / 2 - 5) * 0.55)
            previewVC.configureView(sizeForPreview: cellSize, tracker: tracker)
            
            return previewVC
        }) { [weak self] _ in
            let pinAction: UIAction
            if tracker.pinned {
                pinAction = UIAction(title: "Открепить", handler: { [weak self] _ in
                    try? self?.trackerStore.pinTracker(tracker, value: false)
                })
            } else {
                pinAction = UIAction(title: "Закрепить", handler: { [weak self] _ in
                    try? self?.trackerStore.pinTracker(tracker, value: true)
                })
            }
            
            let editAction = UIAction(title: "Редактировать", handler: { [weak self] _ in
                guard let self = self else { return }
                self.analytics.report("click", params: ["screen": "Main", "item": "edit"])
                let addHabit = CreateTrackerViewController(edit: true)
                addHabit.trackerViewController = self
                addHabit.editTracker(
                    tracker: tracker,
                    category: self.categories.first {
                        $0.trackerMass.contains {
                            $0.id == tracker.id
                        }
                    },
                    completed: self.completedTrackers.filter {
                        $0.id == tracker.id
                    }.count
                )
                self.present(addHabit, animated: true)
                
            })
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.analytics.report("click", params: ["screen": "Main", "item": "delete"])
                
                let alertController = UIAlertController(title: nil, message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
                let deleteConfirmationAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    try? self?.trackerStore.deleteTracker(tracker)
                    self?.uncompleteTracker(id: tracker.id, at: indexPath)
                    self?.showVisibleViews()
                }
                alertController.addAction(deleteConfirmationAction)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            let actions = [pinAction, editAction, deleteAction]
            return UIMenu(title: "", children: actions)
        }
        
        return configuration
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
