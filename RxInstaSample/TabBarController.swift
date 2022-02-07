//
//  TabBarController.swift
//  RxInstaSample
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Auth.auth().currentUser == nil {
            // ログインしていなければログイン画面に遷移
            let storyboard = UIStoryboard(name: "LoginViewController", bundle: nil)
            let loginViewController = storyboard.instantiateInitialViewController()!
            present(loginViewController, animated: true)
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageViewController {
            // 画像選択画面に遷移
            let storyboard = UIStoryboard(name: "ImageViewController", bundle: nil)
            let imageSelectViewController = storyboard.instantiateInitialViewController()!
            present(imageSelectViewController, animated: true)
            return false
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
    }

}
