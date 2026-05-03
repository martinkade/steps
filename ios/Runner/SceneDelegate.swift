//
//  SceneDelegate.swift
//  Runner
//
//  Created by mediaBEAM on 03.05.26.
//

import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
