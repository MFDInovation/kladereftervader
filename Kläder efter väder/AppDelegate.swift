//
//  AppDelegate.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.accessibilityLanguage = "sv-SE"
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return constants.isLandscapeEnabled() ? .all : [.portrait, .portraitUpsideDown]
    }

}

