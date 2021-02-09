

import UIKit

class MITabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemBlue
        viewControllers = [createHomeNC(), /*createWatchlistNC(), createAccountNC(), createSearchNC()*/]
    }
    
    private func createHomeNC() -> UINavigationController {
        let homeVC = HomeViewController()
        homeVC.title = "Home"
        let tvImage = UIImage(systemName: "tv")
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: tvImage, tag: 0)
        return UINavigationController(rootViewController: homeVC)
    }
  
}
