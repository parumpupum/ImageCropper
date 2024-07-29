import UIKit

class TabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

//MARK: -
//MARK: - Configure

private extension TabBar {
    func configure() {
        setAppearance()
        setContollers()
    }
    
    func setAppearance() {
        tabBar.backgroundColor = .white
    }
    
    func setContollers() {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        mainVC.tabBarItem = UITabBarItem(title: "Main", image: UIImage.init(systemName: "folder"), tag: 0)
        
        let settingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage.init(systemName: "gearshape"), tag: 1)
        
        viewControllers = [mainVC, settingsVC]
    }
}
