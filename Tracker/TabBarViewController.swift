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
    }
    
    func createNavController(vc: UIViewController, itemName: String, itemImage: String) -> UINavigationController {
        let item = UITabBarItem(title: itemName, image: UIImage(systemName: itemImage), tag: 0)
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
    }
}
