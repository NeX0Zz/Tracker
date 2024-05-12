import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    var trackerViewController: TrackerViewController?
    
    // MARK: - Private Properties
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var regularlyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(regularlyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Нерегулярные события", for: .normal)
        button.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
        let regularlyButton = CreateTrackerViewController()
        regularlyButton.trackerViewController = self.trackerViewController
        present(regularlyButton, animated: true)
    }
    
    @objc private func irregularButtonTapped() {
        let irregularButton = IrregularViewController()
        irregularButton.trackerViewController = self.trackerViewController
        present(irregularButton, animated: true)
    }
}
