import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        let trackerViewController = createNavController(vc: TrackerViewController(), itemName: "Трекеры", itemImage: "record.circle.fill")
        let statisticViewController = createNavController(vc: StatisticViewController(), itemName: "Статистика", itemImage: "hare.fill")
        viewControllers = [trackerViewController,statisticViewController]
        tabBar.addTopBorder(color: .grayy, thickness: 0.5)
    }
    
    func createNavController(vc: UIViewController, itemName: String, itemImage: String) -> UINavigationController {
        let item = UITabBarItem(title: itemName, image: UIImage(systemName: itemImage), tag: 0)
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
    }
}
extension UITabBar {
    func addTopBorder(color: UIColor?, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        self.addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.leftAnchor.constraint(equalTo: self.leftAnchor),
            subview.rightAnchor.constraint(equalTo: self.rightAnchor),
            subview.heightAnchor.constraint(equalToConstant: thickness),
            subview.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
}
