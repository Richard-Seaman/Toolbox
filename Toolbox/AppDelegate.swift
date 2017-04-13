//
//  AppDelegate.swift
//  Toolbox
//
//  Created by Richard Seaman on 17/07/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Force defaults
        // resetLoadingUnitDefaults()
        // resetDuctSizerPropertiesDefaults()
        
        // Initialise the calculator
        calculator = Calculator()
        
        // If it's the first time launching, reset the MWS defaults
        // (not sure why but MWS max velocity is 0 when first launched)
        var needsToReset:Bool = true
        
        let key:String = "hasResetMWS"
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: key) {
            needsToReset = false
        }
        
        if needsToReset {
            print("First time launching on iPad, resetting MWS due to known bug")
            calculator.resetDefaultFluidProperties(fluid: .MWS)
            userDefaults.set(true, forKey: key)
            userDefaults.synchronize()
        }
        
        // Set up the navigation controller visuals
        UINavigationBar.appearance().barStyle = UIBarStyle.blackTranslucent
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // MARK: - Configure Google Analytics
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
        }
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        // TODO: remove before release
        gai.logger.logLevel = GAILogLevel.verbose  // remove before app release
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

