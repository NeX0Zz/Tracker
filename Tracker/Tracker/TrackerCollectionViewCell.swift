import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    
    weak var delegate: TrackerCellDelegate?
    
    //MARK: - Private Properties
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    private lazy var doneTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "Plus")!,
            target: self,
            action: #selector(completedTracker))
        return button
    }()
    
    private lazy var trackersDaysAmount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let pinnedTracker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pin")
        return imageView
    }()
    
    private lazy var basicLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    private lazy var trackerEmoji: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private lazy var trackerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.width * 0.55)
        return view
    }()
    
    private lazy var emojiBackView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 12, y: 12, width: 24, height: 24)
        view.layer.cornerRadius = view.frame.width / 2
        view.backgroundColor = .white
        view.layer.opacity = 0.3
        return view
    }()
    
    //MARK: - Methods
    
    func configure(tracker: Tracker, completedToday: Bool, completedDays: Int, indexPath: IndexPath) {
        self.isCompletedToday = completedToday
        self.indexPath = indexPath
        self.trackerId = tracker.id
        self.trackerView.backgroundColor = tracker.color
        basicLabel.text = tracker.name
        trackerEmoji.text = tracker.emoji
        trackersDaysAmount.text = formatCompletedDays(completedDays)
        
        let image = completedToday ? (UIImage(named: "Tracker Done")?.withTintColor(trackerView.backgroundColor ?? .white)) : (UIImage(named: "Plus")?.withTintColor(trackerView.backgroundColor ?? .white))
        doneTrackerButton.setImage(image, for: .normal)
        doneTrackerButton.tintColor = trackerView.backgroundColor
        self.pinnedTracker.isHidden = tracker.pinned ? false : true
    }
    
    //MARK: - Override Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(trackerView)
        contentView.addSubview(doneTrackerButton)
        trackerView.addSubview(emojiBackView)
        
        [basicLabel,trackerEmoji,trackersDaysAmount,pinnedTracker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            trackerView.addSubview($0)
        }
        doneTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerEmoji.centerXAnchor.constraint(equalTo: emojiBackView.centerXAnchor),
            trackerEmoji.centerYAnchor.constraint(equalTo: emojiBackView.centerYAnchor),
            
            trackersDaysAmount.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16),
            trackersDaysAmount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            doneTrackerButton.centerYAnchor.constraint(equalTo: trackersDaysAmount.centerYAnchor),
            doneTrackerButton.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            
            pinnedTracker.centerYAnchor.constraint(equalTo: trackerEmoji.centerYAnchor),
            pinnedTracker.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            
            basicLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            basicLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
        ])
    }
    
    //MARK: - Private Methods
    
    private func formatCompletedDays(_ completedDays: Int) -> String {
        let lastDigit = completedDays % 10
        let lastTwoDigits = completedDays % 100
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(completedDays) \(NSLocalizedString("trackerCell.day.title", comment: ""))"
        }
        switch lastDigit {
        case 1: return "\(completedDays) \(NSLocalizedString("trackerCell.day.title", comment: ""))"
        case 2, 3, 4: return "\(completedDays) \(NSLocalizedString("trackerCell.day.genetive.title", comment: ""))"
        default: return "\(completedDays) \(NSLocalizedString("trackerCell.days.title", comment: ""))"
        }
    }
    
    
    @objc private func completedTracker() {
        guard let trackerId = trackerId, let indexPath = indexPath else { assertionFailure("No Id"); return }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    func update(with pinned: UIImage) {
        pinnedTracker.image = pinned
    }
}
