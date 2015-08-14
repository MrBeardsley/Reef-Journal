//
//  AppDelegate.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var dataLayer: DataPersistence = DataPersistence()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Application Delegate Protocol Methods

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // Handle setting up the split view
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self

        let detailNavController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        detailNavController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()


        // Inject the data access object into the first view controller
        let parametersNavContoller = splitViewController.viewControllers[0] as! UINavigationController
        for controller in parametersNavContoller.viewControllers {
            if controller is ParametersTableViewController {
                if let parametersController = controller as? ParametersTableViewController {
                    parametersController.dataAccess = dataLayer
                }
            }
        }

        // Get the preferences setup
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: NSUserDefaultsDidChangeNotification, object:nil)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.synchronize()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.dataLayer.saveContext()
    }

    func preferencesDidChange(notification: NSNotification?) {
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName("PreferencesChanged", object: nil)
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.parameterType == nil {
             // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
}

