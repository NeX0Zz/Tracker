import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    var trackerViewController: TrackersActions?
    let cellReuseIdentifier = "CreateTrackerTableViewCell"
    
    // MARK: - Private Properties
    
    private var selectedCategory: TrackerCategory?
    var selectedDays: [WeekDay] = []
    
    private let header: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        return label
    }()
    
    private let addTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.becomeFirstResponder()
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.redd, for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.redd.cgColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackersTableView: UITableView = {
        let trackersTableView = UITableView()
        return trackersTableView
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "clean"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        button.isHidden = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        paddingView.addSubview(button)
        addTextField.rightView = paddingView
        addTextField.rightViewMode = .whileEditing
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        button.setTitleColor(.whiteDay, for: .normal)
        button.backgroundColor = .grayy
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        addTextField.delegate = self
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(CreateTrackerViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        trackersTableView.layer.cornerRadius = 16
        trackersTableView.separatorStyle = .none
    }
    
    private func setup(){
        [createButton, addTextField, trackersTableView, cancelButton, createButton, header].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addTextField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addTextField.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            addTextField.heightAnchor.constraint(equalToConstant: 75),
            addTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersTableView.topAnchor.constraint(equalTo: addTextField.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 149),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width/2) - 4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.frame.width/2) + 4)
        ])
        
    }
    
    // MARK: - Priavte Methods
    
    @objc private func clearTextField() {
        addTextField.text = ""
        clearButton.isHidden = true
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        if !selectedDays.isEmpty {
            createButton.isEnabled = false
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        guard let text = addTextField.text, !text.isEmpty  else { return }
        let newTracker = Tracker(name: text, color: .bluee, emoji: "👂🏿", timetable: selectedDays)
        trackerViewController?.appendTracker(tracker: newTracker)
        trackerViewController?.reload()
    }
}

// MARK: - SelectedDays

extension CreateTrackerViewController: SelectedDays {
    func save(indicies: [Int]) {
        for index in indicies {
            self.selectedDays.append(WeekDay.allCases[index])
            self.trackersTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CreateTrackerViewCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            var title = "Категория"
            if let selectedCategory = selectedCategory {
                print(selectedCategory)
                title += "\n" + selectedCategory.header
            }
            cell.update(with: title)
        } else if indexPath.row == 1 {
            var subtitle = ""
            
            if !selectedDays.isEmpty {
                if selectedDays.count == 7 {
                    subtitle = "Каждый день"
                } else {
                    subtitle = selectedDays.map { $0.shortDaysName }.joined(separator: ", ")
                }
            }
            if !subtitle.isEmpty {
                cell.update(with: !subtitle.isEmpty ? "Расписание\n" + subtitle : "Расписание")
            } else {
                cell.update(with: "Расписание")
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let regularlyViewController = RegularlyViewController()
            regularlyViewController.createTrackerViewController = self
            present(regularlyViewController, animated: true, completion: nil)
        }
        trackersTableView.deselectRow(at: indexPath, animated: true)
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
}

// MARK: - UITextFieldDelegate

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        if textField.text?.isEmpty ?? false {
            createButton.isEnabled = false
            createButton.backgroundColor = .grayy
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackDay
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
