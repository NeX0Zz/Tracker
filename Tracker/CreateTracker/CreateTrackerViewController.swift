import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    var trackerViewController: TrackersActions?
    let cellReuseIdentifier = "CreateTrackerTableViewCell"
    
    // MARK: - Private Properties
    
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
                                   "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedColorIndex: Int?
    private var selectedCategory: TrackerCategory?
    private let addCategoryViewController = CategoryViewController()
    var selectedDays: [WeekDay] = []
    private let colors: [UIColor] = [.ypColorSelection1, .ypColorSelection2, .ypColorSelection3,
        .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9,
        .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15,
        .ypColorSelection16, .ypColorSelection17, .ypColorSelection18]
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        return label
    }()
    
    private lazy var addTextField: UITextField = {
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
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiViewCollectionCell.self, forCellWithReuseIdentifier: EmojiViewCollectionCell.reuseId)
        collectionView.register(EmojiHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiHeaderView.id)
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: ColorsCollectionViewCell.reuseId)
        collectionView.register(ColorHeaderViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorHeaderViewCell.id)
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        addTextField.delegate = self
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(CreateTrackerViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        trackersTableView.layer.cornerRadius = 16
        trackersTableView.separatorStyle = .none
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }
    
    private func setup(){
        view.addSubview(scrollView)
        [createButton, addTextField, trackersTableView, cancelButton, createButton, header, emojiCollectionView, colorCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            header.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            header.heightAnchor.constraint(equalToConstant: 22),
            
            addTextField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addTextField.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            addTextField.heightAnchor.constraint(equalToConstant: 75),
            addTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            addTextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            
            trackersTableView.topAnchor.constraint(equalTo: addTextField.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 149),
            
            emojiCollectionView.topAnchor.constraint(equalTo: trackersTableView.bottomAnchor, constant: 32),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            createButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: 4)
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
        guard let text = addTextField.text, !text.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let selectedCategory = selectedCategory
        else { return }
        let newTracker = Tracker(id: UUID(), name: text, color: color, emoji: emoji, timetable: selectedDays)
        trackerViewController?.appendTracker(tracker: newTracker, category: selectedCategory.header)
        addCategoryViewController.viewModel.addTrackerToCategory(to: selectedCategory, tracker: newTracker)
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
            
            trackersTableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.row == 0 {
            addCategoryViewController.viewModel.$selectedCategory.bind { [weak self] categoryName in
                self?.selectedCategory = categoryName
                self?.trackersTableView.reloadData()
            }
            present(addCategoryViewController, animated: true, completion: nil)
        }}
    
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

// MARK: - UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiViewCollectionCell else {
                return UICollectionViewCell()
            }
            let emojiIndex = indexPath.item % emoji.count
            let selectedEmoji = emoji[emojiIndex]
            
            cell.emoji.text = selectedEmoji
            cell.layer.cornerRadius = 16
            
            if let passedEmoji = self.selectedEmoji {
                if passedEmoji == selectedEmoji {
                    cell.backgroundColor = .lightGrayy
                }
            }
            
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsCollectionViewCell", for: indexPath) as? ColorsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let colorIndex = indexPath.item % colors.count
            let selectedColor = colors[colorIndex]
            
            cell.colorView.backgroundColor = selectedColor
            cell.layer.cornerRadius = 8
            
            if let passedColorIndex = self.selectedColorIndex {
                if passedColorIndex == colorIndex {
                    cell.layer.borderWidth = 3
                    cell.layer.borderColor = cell.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiHeaderView.id, for: indexPath) as? EmojiHeaderView else {
                return UICollectionReusableView()
            }
            header.headerText = "Emoji"
            return header
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ColorHeaderViewCell.id, for: indexPath) as? ColorHeaderViewCell else {
                return UICollectionReusableView()
            }
            header.headerText = "Цвет"
            return header
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width - 36
        let cellWidth = collectionViewWidth / 6
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
}

// MARK: - UICollectionViewDelegate

extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiViewCollectionCell
            cell?.backgroundColor = .lightGrayy
            
            selectedEmoji = cell?.emoji.text} else
        if collectionView == colorCollectionView {
            collectionView.visibleCells.forEach {
                $0.layer.borderWidth = 0
            }
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            
            selectedColor = cell?.colorView.backgroundColor
            selectedColorIndex = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiViewCollectionCell
            cell?.backgroundColor = .white
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell
            cell?.layer.borderWidth = 0
        }
    }
}
