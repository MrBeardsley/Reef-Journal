//
//  AppDelegate.swift
//  Reef Journal
//
//  Created by Christopher Harding on 6/10/14.
//  Copyright (c) 2014 Christopher Harding. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.

        let mainBundlePath = NSBundle.mainBundle().bundlePath
        let settingsPropertyListPath = mainBundlePath.stringByAppendingPathComponent("Settings.bundle/Root.plist");

        let settingsPropertyList = NSDictionary(contentsOfFile: settingsPropertyListPath)

        if let preferencesArray = settingsPropertyList.objectForKey("PreferenceSpecifiers") as? Array<AnyObject> {
            var registerableDictionary = NSMutableDictionary()

            for index in 0..preferencesArray.count {
                let item: AnyObject = preferencesArray[index]
                if let preference = item as? NSDictionary {
                    if let type = preference.objectForKey("Type") as? NSString {
                        if type != "PSGroupSpecifier" {
                            registerableDictionary.setObject(preference.valueForKey("DefaultValue"), forKey: preference.valueForKey("Key") as NSString)
                        }
                    }
                }
            }

            NSUserDefaults.standardUserDefaults().registerDefaults(registerableDictionary)

        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        NSUserDefaults.standardUserDefaults().synchronize()
//        println(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().description)
//        NSNotificationCenter.defaultCenter().postNotificationName("PreferencesChanged", object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

