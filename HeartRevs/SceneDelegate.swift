//
//  SceneDelegate.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 23/09/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import UIKit
import SwiftUI

class HRMReaderReceiver: ObservableObject, HRMReaderDelegate {
    func didUpdate(bpm: Int) {
        self.bpm = Double(bpm)
    }
    
    func didEncounter(error: String) {
        self.error = error
    }
    
    @Published var bpm: Double = 62
    @Published var error: String?
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var hrmReader: HRMReader?
    var contentView: SwiftUIHRMView?
    var hrmReceiver: HRMReaderReceiver?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let receiver = HRMReaderReceiver()
        self.hrmReceiver = receiver
        self.contentView = SwiftUIHRMView()
        
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: self.contentView.environmentObject(receiver))
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if let receiver = self.hrmReceiver {
            self.hrmReader = HRMReader(delegate:receiver)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        self.hrmReader?.willDeactivate()
        self.hrmReader = nil
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

