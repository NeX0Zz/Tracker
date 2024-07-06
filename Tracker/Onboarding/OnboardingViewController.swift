import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private var pages: [UIViewController] = []
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .blackDay
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.blackDay.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil) {
            super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        setupOnboardingPages()
        setupSubviews()
        setupConstraints()
    }
    
    @objc func buttonTapped() {
        let tabBarController = TabBarViewController()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = tabBarController
    }
}


// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - Private Methods

private extension OnboardingViewController {
    func setupOnboardingPages() {
        
        let page1 = createPage(image: "BackgroundImage1",label: "Отслеживайте только то, что хотите")
        let page2 = createPage(image: "BackgroundImage2",label: "Даже если это\nне литры воды и йога")
        
        pages.append(page1)
        pages.append(page2)
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func setupSubviews() {
        [pageControl,button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 594),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 24),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func createPage(image: String, label: String) -> UIViewController {
        let VC = UIViewController()
        
        let imageView = UIImageView(image: UIImage(named: image))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        VC.view.addSubview(imageView)
        
        let labelText = UILabel()
        labelText.text = label
        labelText.textAlignment = .center
        labelText.numberOfLines = 2
        labelText.textColor = .blackDay
        labelText.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        labelText.translatesAutoresizingMaskIntoConstraints = false
        VC.view.addSubview(labelText)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: VC.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: VC.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: VC.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: VC.view.trailingAnchor),
            
            labelText.centerXAnchor.constraint(equalTo: VC.view.centerXAnchor),
            labelText.topAnchor.constraint(equalTo: VC.view.topAnchor, constant: 452),
            labelText.leadingAnchor.constraint(equalTo: VC.view.leadingAnchor, constant: 16),
            labelText.trailingAnchor.constraint(equalTo: VC.view.trailingAnchor, constant: -16)
        ])
        
        return VC
    }
}




