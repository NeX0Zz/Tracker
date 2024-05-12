import UIKit

protocol TrackersActions {
    func appendTracker(tracker: Tracker)
    func reload()
}

final class IrregularViewController: UIViewController {
    
    // MARK: - Properties
    
    let irregularCellReuseIdentifier = "IrregularEventTableViewCell"
    var trackerViewController: TrackersActions?
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Новое нерегулярное событие"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    // MARK: - Private Properties
    
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
    
    private let addTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = view
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.keyboardType = .default
        textField.becomeFirstResponder()
        return textField
    }()
    
    private lazy var irregularTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.whiteDay, for: .normal)
        button.backgroundColor = .grayy
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
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
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        irregularTableView.delegate = self
        irregularTableView.dataSource = self
        irregularTableView.register(IrregularViewCell.self, forCellReuseIdentifier: irregularCellReuseIdentifier)
        irregularTableView.layer.cornerRadius = 16
        irregularTableView.separatorStyle = .none
        addTextField.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func setup(){
        [header,addTextField,irregularTableView,cancelButton,createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addTextField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addTextField.heightAnchor.constraint(equalToConstant: 75),
            
            irregularTableView.topAnchor.constraint(equalTo: addTextField.bottomAnchor, constant: 24),
            irregularTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularTableView.heightAnchor.constraint(equalToConstant: 75),
            
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
    
    @objc private func clearTextField() {
        addTextField.text = ""
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let text = addTextField.text, !text.isEmpty else {
            return
        }
        let newEvent = Tracker(name: text, color: .bluee, emoji: "🦾", timetable: WeekDay.allCases)
        trackerViewController?.appendTracker(tracker: newEvent)
        print(newEvent)
        trackerViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension IrregularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        irregularTableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension IrregularViewController: UITextFieldDelegate {
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

// MARK: - UITableViewDataSource

extension IrregularViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: irregularCellReuseIdentifier, for: indexPath) as! IrregularViewCell
        cell.titleLabel.text = "Категория"
        return cell
    }
}
