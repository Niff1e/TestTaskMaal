//
//  SceneDelegate.swift
//  TestTaskMaal
//
//  Created by Pavel Maal on 16.01.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let navVC = UINavigationController(rootViewController: ViewController())
        navVC.navigationBar.prefersLargeTitles = true
        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
}
