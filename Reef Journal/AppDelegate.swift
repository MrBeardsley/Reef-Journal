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

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    var window: UIWindow?
    var dataPersistence = DataPersistence()
    
    // MARK: - Private Properties
    private var dataModel: AppData!
    private var parameterListViewController: ParameterListViewController!

    // MARK: - Application Lifecycle

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        guard let window = self.window else { return false }
        guard let svc = window.rootViewController as? UISplitViewController else { return false }

        dataModel = AppData()
        svc.delegate = self
        
        if let paramListNav = svc.viewControllers.first as? UINavigationController,
               paramListView = paramListNav.topViewController as? ParameterListViewController {
               
           parameterListViewController = paramListView
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
        
        // Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshQuickActions:", name: "SavedValue", object:nil)

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
        
        refreshQuickActions(nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

// MARK: - Notification Handlers

extension AppDelegate {
    
    func refreshQuickActions(aNotification: NSNotification?) {
        guard let model = dataModel else { return }
        
        var quickActions = [UIApplicationShortcutItem]()
        let mostUsed = model.mostUsedParameters
        
        for param in mostUsed {
            let addIcon = UIApplicationShortcutIcon(type: .Add)
            var subtitle: String
            switch param.1 {
            case 0:
                subtitle = "No Measurements"
            case 1:
                subtitle = "1 Measurement"
            default:
                subtitle = "\(param.1) Measurements"
            }
            
            quickActions.append(UIApplicationShortcutItem(type: "\(param.0)", localizedTitle: "New \(param.0)", localizedSubtitle: subtitle, icon: addIcon, userInfo: nil))
        }
        
        UIApplication.sharedApplication().shortcutItems = quickActions
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
        
        guard let svc = window?.rootViewController as? UISplitViewController,
                  navController = svc.viewControllers.first as? UINavigationController,
                  topViewController = navController.topViewController,
                  param = Parameter(rawValue: shortcutItem.type) where
                  enabledChemistryParameters.contains(param) || enabledNutrientParameters.contains(param)
        else { return }
        
        if svc.collapsed {
            print("Collapsed")
            print(svc.viewControllers.count)
        } else {
            print("Not Collapsed")
            print(svc.viewControllers.count)
        }
        
        switch topViewController {
        case let list as ParameterListViewController:
            let dict: NSDictionary = ["currentParamter" : param.rawValue]
            list.performSegueWithIdentifier("showDetail", sender: dict)
        case let nav as UINavigationController:
            // If it is a navigation controller it is either the Detail or Graph view Controller
            switch nav.topViewController {
            case let detail as DetailViewController:
                detail.currentParameter = param
                detail.refreshData()
            case is GraphViewController:
                nav.popViewControllerAnimated(false)
                if let detail = nav.topViewController as? DetailViewController {
                    detail.currentParameter = param
                    detail.refreshData()
                }
            default:
                break
            }
        default:
            break
        }
        
        // Make sure we get the right selection for the parameter list table view controller
        var section = 0
        var row = 0
        
        if let index = enabledChemistryParameters.indexOf(param) {
            section = 0
            row = index
        }
        
        if let index = enabledNutrientParameters.indexOf(param) {
            section = 1
            row = index
        }
        
        let index = NSIndexPath(forRow: row, inSection: section)
        parameterListViewController.tableView?.selectRowAtIndexPath(index, animated: false, scrollPosition: .Middle)
        
        
        completionHandler(true)
    }
}


// MARK: - Split View Controller Delegate Conformance

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        
        if let detailNav = secondaryViewController as? UINavigationController,
               detail = detailNav.topViewController as? DisplaysInDetailViewType {
            return detail.shouldCollapseSplitView
        }
        
        return false
    }
}

// MARK: - EnableParametersType Conformance

extension AppDelegate: EnableParametersType { }