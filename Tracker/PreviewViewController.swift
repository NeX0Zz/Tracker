import UIKit

final class PreviewViewController: UIViewController {
    private var previewSize: CGSize? {
        didSet {
            if let size = previewSize {
                self.preferredContentSize = size
            }
        }
    }
    
    private let trackerDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var trackerCard: UIView = {
        let view = UIView()
        return view
    }()
    
    private let emojiBackground: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 12, y: 12, width: 24, height: 24)
        view.backgroundColor = .white
        view.layer.cornerRadius = view.frame.width / 2
        view.layer.opacity = 0.3
        return view
    }()
    
    private let trackerEmoji: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let pinnedTracker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pin")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func configureView(sizeForPreview: CGSize, tracker: Tracker) {
        previewSize = sizeForPreview
        trackerCard.backgroundColor = tracker.color
        trackerEmoji.text = tracker.emoji
        trackerDescription.text = tracker.name
        self.pinnedTracker.isHidden = tracker.pinned ? false : true
        print(tracker)
    }
    
    private func setup() {
        [trackerCard,emojiBackground,trackerEmoji,trackerDescription,pinnedTracker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            trackerCard.topAnchor.constraint(equalTo: view.topAnchor),
            trackerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emojiBackground.topAnchor.constraint(equalTo: trackerCard.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalTo: emojiBackground.widthAnchor),
            
            trackerEmoji.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            trackerEmoji.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            trackerDescription.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            trackerDescription.bottomAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: -12),
            
            pinnedTracker.centerYAnchor.constraint(equalTo: trackerEmoji.centerYAnchor),
            pinnedTracker.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -12)
        ])
    }
}
