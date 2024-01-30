import UIKit

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let homeViewController = HomeController()
            let navigationController = UINavigationController(rootViewController: homeViewController)
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }

    }
}
