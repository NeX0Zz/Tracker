import UIKit

protocol TrackersActions {
    func appendTracker(tracker: Tracker, category: String?)
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?)
    func reload()
    func filterTrackers(forToday: Bool)
}

final class IrregularViewController: UIViewController {
    
    // MARK: - Properties
    
    let irregularCellReuseIdentifier = "IrregularEventTableViewCell"
    var trackerViewController: TrackersActions?
    private var selectedColor: UIColor?
    private var selectedCategory: TrackerCategory?
    private var selectedColorIndex: Int?
    private let addCategoryViewController = CategoryViewController()
    private var selectedEmoji: String?
    private let colors: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3,
        .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9,
        .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15,
        .ypColorSelection16, .ypColorSelection17, .ypColorSelection18]
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
                                   "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = NSLocalizedString("irregularEvent.title", comment: "")
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
        textField.placeholder = NSLocalizedString("createTracker.textField.addTrackerName.placeholder", comment: "")
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
        button.setTitle(NSLocalizedString("button.create.title", comment: ""), for: .normal)
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
        button.setTitle(NSLocalizedString("button.cancel.title", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
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
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        addTextField.delegate = self
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    // MARK: - Private Methods
    
    private func setup(){
        view.addSubview(scrollView)
        [header,addTextField,irregularTableView,cancelButton,createButton,emojiCollectionView,colorCollectionView].forEach {
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
            
            irregularTableView.topAnchor.constraint(equalTo: addTextField.bottomAnchor, constant: 24),
            irregularTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            irregularTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            irregularTableView.heightAnchor.constraint(equalToConstant: 75),
            
            emojiCollectionView.topAnchor.constraint(equalTo: irregularTableView.bottomAnchor, constant: 32),
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
    
    @objc private func clearTextField() {
        addTextField.text = ""
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let text = addTextField.text, !text.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let selectedCategory = selectedCategory
        else { return }
        let newEvent = Tracker(id: UUID(),
                               name: text,
                               color: color,
                               emoji: emoji,
                               timetable: [TrackerViewController().getDate()],
                               pinned: false,
                               colorIndex: 0
        )
        trackerViewController?.appendTracker(tracker: newEvent, category: selectedCategory.header)
        addCategoryViewController.viewModel.addTrackerToCategory(to: selectedCategory, tracker: newEvent)
        trackerViewController?.reload()
        trackerViewController?.filterTrackers(forToday: true)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension IrregularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addCategoryViewController = CategoryViewController()
        addCategoryViewController.viewModel.$selectedCategory.bind { [weak self] categoryName in
            self?.selectedCategory = categoryName
            self?.irregularTableView.reloadData()
        }
        irregularTableView.deselectRow(at: indexPath, animated: true)
        present(addCategoryViewController, animated: true, completion: nil)
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
            var title = NSLocalizedString("createTracker.cell.category.title", comment: "")
            if let selectedCategory = selectedCategory {
                title += "\n" + selectedCategory.header
            }
            cell.update(with: title)
            return cell
    }
}

extension IrregularViewController: UICollectionViewDataSource {
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
            header.headerText = NSLocalizedString("createTracker.header.color.title", comment: "")
            return header
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension IrregularViewController: UICollectionViewDelegateFlowLayout {
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

extension IrregularViewController: UICollectionViewDelegate {
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
