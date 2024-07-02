import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func allTrackers()
    func trackersToday()
    func completedTrackersToday()
    func unCompletedTrackersToday()
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    static var filterIndex: Int = 0
    private var trackerFilters: [Filters] = Filters.allCases
    private var selectedFilter: Filters?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filterTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .grayy
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupFilterTableView()
        setupFilterView()
        setupFilterViewConstrains()
    }
    
    // MARK: - Setup View
    
    private func setupFilterTableView() {
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.register(FilterCell.self,
                                 forCellReuseIdentifier: FilterCell.cellIdentifier)
    }
    
    private func setupFilterView() {
        view.addSubview(titleLabel)
        view.addSubview(filterTableView)
    }
    
    private func setupFilterViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == Filters.allCases.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: 500)
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 16,
                                               bottom: 0,
                                               right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            delegate?.allTrackers()
        case 1:
            delegate?.trackersToday()
        case 2:
            delegate?.completedTrackersToday()
        case 3:
            delegate?.unCompletedTrackersToday()
        default:
            break
        }
        selectedFilter = trackerFilters[indexPath.row]
        FilterViewController.filterIndex = indexPath.row
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return trackerFilters.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterCell.cellIdentifier,
            for: indexPath) as? FilterCell else { return UITableViewCell() }
        let filterText = trackerFilters[indexPath.row]
        
        cell.textLabel?.text = filterText.description
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        
        if indexPath.row == FilterViewController.filterIndex {
            cell.accessoryType = .checkmark
            cell.tintColor = .bluee
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

