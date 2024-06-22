import UIKit

final class CategoryViewController: UIViewController {
    
    let cellReuseIdentifier = "CreateCategoryViewController"
    private(set) var viewModel: CategoryViewModel = CategoryViewModel.shared
    
    private let header: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        return label
    }()
    
    private let emptyText: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let emptyLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        return imageView
    }()
    
    private lazy var addCategory: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        checkCategories()
        view.backgroundColor = .white
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.register(CategoryCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
    }
    
    private func checkCategories(){
        if !viewModel.categories.isEmpty {
            categoriesTableView.isHidden = false
            emptyLogo.isHidden = true
            emptyText.isHidden = true
        }
    }
    
    private func setup(){
        [header, categoriesTableView, emptyLogo, emptyText, addCategory].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
       
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoriesTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategory.topAnchor, constant: -16),
            
            emptyLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLogo.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 246),
            emptyLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyLogo.widthAnchor.constraint(equalToConstant: 80),
            
            emptyText.centerXAnchor.constraint(equalTo: emptyLogo.centerXAnchor),
            emptyText.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
            
            addCategory.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategory.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func addCategoryTapped() {
        let сreateCategoryViewController = CreateCategoryViewController()
        сreateCategoryViewController.categoryViewController = self
        present(сreateCategoryViewController, animated: true, completion: nil)
    }
}

// MARK: - CategoryActions

extension CategoryViewController: CategoryActions {
    func appendCategory(category: String) {
        viewModel.addCategory(category)
        categoriesTableView.isHidden = false
        emptyLogo.isHidden = true
        emptyText.isHidden = true
    }
    
    func reload() {
        self.categoriesTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CategoryCell else { return UITableViewCell() }
        
        if indexPath.row < viewModel.categories.count {
            let category = viewModel.categories[indexPath.row]
            cell.update(with: category.header)
            if let selected = viewModel.selectedCategory {
                if selected.header == category.header {
                    cell.done(with: UIImage(named: "Done") ?? UIImage())
                }
            }
            
            let isLastCell = indexPath.row == viewModel.categories.count - 1
            if isLastCell {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.cornerRadius = 0
                cell.layer.masksToBounds = false
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.categories.count else {
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
            cell.done(with: UIImage(named: "Done") ?? UIImage())
            viewModel.selectCategory(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if !isLastCell {
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = .grayy
            cell.addSubview(separatorView)
        }
    }
}
