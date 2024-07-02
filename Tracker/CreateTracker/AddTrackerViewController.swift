import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    var trackerViewController: TrackerViewController?
    
    // MARK: - Private Properties
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("addTracker.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var regularlyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("addTracker.habbitButton.title", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(regularlyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle(NSLocalizedString("addTracker.irregularButton.title", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            irregularButton.backgroundColor = .white
            irregularButton.setTitleColor(.black, for: .normal)
            regularlyButton.setTitleColor(.black, for: .normal)
            regularlyButton.backgroundColor = .white
        } else {
            irregularButton.backgroundColor = .black
            irregularButton.setTitleColor(.white, for: .normal)
            regularlyButton.setTitleColor(.white, for: .normal)
            regularlyButton.backgroundColor = .black
        }
    }
    
    //MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        view.backgroundColor = .systemBackground
    }
    
    //MARK: - private Methods
    
    private func setup(){
        [header,regularlyButton,irregularButton,header].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            regularlyButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 295),
            regularlyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            regularlyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            regularlyButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularButton.topAnchor.constraint(equalTo: regularlyButton.bottomAnchor, constant: 16),
            irregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func regularlyButtonTapped() {
        let regularlyButton = CreateTrackerViewController(edit: false)
        regularlyButton.trackerViewController = self.trackerViewController
        present(regularlyButton, animated: true)
    }
    
    @objc private func irregularButtonTapped() {
        let irregularButton = IrregularViewController()
        irregularButton.trackerViewController = self.trackerViewController
        present(irregularButton, animated: true)
    }
}
