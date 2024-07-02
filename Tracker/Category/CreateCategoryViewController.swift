import UIKit

protocol CategoryActions {
    func appendCategory(category: String)
    func reload()
}

final class CreateCategoryViewController: UIViewController {
    
    var categoryViewController: CategoryActions?
    
    private let header: UILabel = {
        let header = UILabel()
        header.text = NSLocalizedString("createTracker.cell.category.title", comment: "")
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    private let addCategoryName: UITextField = {
        let addCategoryName = UITextField()
        addCategoryName.placeholder = NSLocalizedString("category.enter", comment: "")
        addCategoryName.backgroundColor = .backgroundDay
        addCategoryName.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        addCategoryName.leftView = leftView
        addCategoryName.leftViewMode = .always
        addCategoryName.keyboardType = .default
        addCategoryName.returnKeyType = .done
        addCategoryName.becomeFirstResponder()
        return addCategoryName
    }()
    
    private lazy var clearButton: UIButton = {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "cleanKeyboard"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        paddingView.addSubview(clearButton)
        addCategoryName.rightView = paddingView
        addCategoryName.rightViewMode = .whileEditing
        return clearButton
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .custom)
        doneButton.setTitle(NSLocalizedString("button.done.title", comment: ""), for: .normal)
        doneButton.setTitleColor(.whiteDay, for: .normal)
        doneButton.backgroundColor = .grayy
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.isEnabled = false
        return doneButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        addCategoryName.delegate = self
    }
    
    private func setup() {
        [header, doneButton, addCategoryName].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
                header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                addCategoryName.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
                addCategoryName.centerXAnchor.constraint(equalTo: header.centerXAnchor),
                addCategoryName.heightAnchor.constraint(equalToConstant: 75),
                addCategoryName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                addCategoryName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
                doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                doneButton.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
    
    @objc private func doneButtonTapped() {
        guard let category = addCategoryName.text, !category.isEmpty else {
            return
        }
        categoryViewController?.appendCategory(category: category)
        categoryViewController?.reload()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func clearTextField() {
        addCategoryName.text = ""
        clearButton.isHidden = true
    }
}

// MARK: - UITextFieldDelegate

extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        if textField.text?.isEmpty ?? false {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .grayy
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .blackDay
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
