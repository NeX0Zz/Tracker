import UIKit

protocol SelectedDays {
    func save(indicies: [Int])
}

final class RegularlyViewController: UIViewController {
    
    //MARK: - Properties
    
    let regularlyCellReuseIdentifier = "regularlyTableViewCell"
    var createTrackerViewController: SelectedDays?
    
    //MARK: - Private Properties
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("schedule.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var regularlyTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.whiteDay, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle(NSLocalizedString("button.done.title", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            doneButton.backgroundColor = .white
            doneButton.setTitleColor(.black, for: .normal)
        } else {
            doneButton.backgroundColor = .black
            doneButton.setTitleColor(.white, for: .normal)
        }
    }
    
    //MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        regularlyTableView.delegate = self
        regularlyTableView.dataSource = self
        regularlyTableView.register(RegularlyViewCell.self, forCellReuseIdentifier: regularlyCellReuseIdentifier)
        regularlyTableView.layer.cornerRadius = 16
        regularlyTableView.separatorStyle = .none
    }
    
    //MARK: - Private Methods
    
    private func setup(){
        [header,regularlyTableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            regularlyTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30),
            regularlyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            regularlyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            regularlyTableView.heightAnchor.constraint(equalToConstant: 524),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonTapped() {
        var selected: [Int] = []
        for (index, elem) in regularlyTableView.visibleCells.enumerated() {
            guard let cell = elem as? RegularlyViewCell else {
                return
            }
            if cell.selectedDay {
                selected.append(index)
            }
        }
        self.createTrackerViewController?.save(indicies: selected)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RegularlyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: regularlyCellReuseIdentifier, for: indexPath) as? RegularlyViewCell else { return UITableViewCell() }
        
        let dayOfWeek = WeekDay.allCases[indexPath.row]
        cell.update(with: "\(dayOfWeek.name)")
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RegularlyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .grayy
        
        cell.addSubview(separatorView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        regularlyTableView.deselectRow(at: indexPath, animated: true)
    }
}
