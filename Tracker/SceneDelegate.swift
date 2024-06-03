//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Malik Timurkaev on 04.04.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
         window = UIWindow(windowScene: scene)
        
        if UserDefaultsManager.wasOnboardinShown == false {
            window?.rootViewController = OnboardingViewController()
        } else {
            window?.rootViewController = TabBarControler()
        }
        window?.makeKeyAndVisible()
        
        if var viewController = window?.rootViewController?.children.first(where: {$0.isViewLoaded}) {
            
            if let navigationController = viewController as? UINavigationController,
               let visibleController = navigationController.visibleViewController {
                
                viewController = visibleController
            }
            
            AnalyticsService.report(event: "open", params: ["screen": "\(viewController)"])
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

