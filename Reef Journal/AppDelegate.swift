//
//  AppDelegate.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    var window: UIWindow?
    var dataPersistence = DataPersistence()
    var dataModel = AppData()

    // MARK: - Application Lifecycle

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        guard let window = self.window else { return false }
        guard let svc = window.rootViewController as? UISplitViewController else { return false }

        dataModel.dataPersistence = dataPersistence
        svc.delegate = self

        // Inject the core data stack into the first view controller
        let parametersNavContoller = svc.viewControllers[0] as! UINavigationController
        for controller in parametersNavContoller.viewControllers {
            if let parametersController = controller as? ParametersTableViewController {
                parametersController.dataPersistence = dataPersistence
            }
        }
        
        // Inject the core data stack into the second view controller
        let detailNavController = svc.viewControllers[svc.viewControllers.count-1] as! UINavigationController
        for controller in detailNavController.viewControllers {
            if let detailViewController = controller as? DetailViewController {
                detailViewController.dataPersistence = dataPersistence
            }
        }

        // Register settings from a plist
        let mainBundlePath = NSBundle.mainBundle().bundlePath as NSString
        let settingsPropertyListPath = mainBundlePath.stringByAppendingPathComponent("Settings.bundle/Root.plist");

        if let settingsPropertyList = NSDictionary(contentsOfFile: settingsPropertyListPath as String) {
            if let preferencesArray = settingsPropertyList.objectForKey("PreferenceSpecifiers") as? Array<NSDictionary> {
                var registerableDictionary = Dictionary<String,AnyObject>()

                for preference in preferencesArray {
                    if let type = preference.objectForKey("Type") as? String {
                        if type != "PSGroupSpecifier" {
                            registerableDictionary[preference["Key"] as! String] = preference["DefaultValue"]
                        }
                    }
                }

                registerableDictionary["LastParameter"] = "Default"

                NSUserDefaults.standardUserDefaults().registerDefaults(registerableDictionary)
            }
        }
        
        // Create the dynamic Quick Actions
        var quickActions = [UIApplicationShortcutItem]()
        let mostUsed = dataModel.mostUsedParameters()
        
        for item in mostUsed {
            quickActions.append(UIApplicationShortcutItem(type: "com.ReefJournal.Add\(item)Measurement", localizedTitle: item))
        }
        
        UIApplication.sharedApplication().shortcutItems = quickActions

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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        NSUserDefaults.standardUserDefaults().synchronize()
        dataPersistence.saveContext()
    }
}

// MARK: - State restoration

extension AppDelegate {
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
}

// MARK: - 3D Touch Quick Actions

extension AppDelegate {
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
    }
}


// MARK: - Split View Controller Delegate Conformance

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        // Called for iPhone screen sizes, but not iPads
        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return true
    }
}
