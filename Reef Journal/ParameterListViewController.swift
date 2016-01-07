//
//  ParameterListViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


class ParameterListViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Init / Deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: NSUserDefaultsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: "SavedValue", object:nil)
    }

    // MARK: - Reloading the data in the table view

    func reloadTableView(aNotification: NSNotification?) {
        tableView?.reloadData()
    }
    
    
    // MARK: - Interface Actions
    
    @IBAction func editParameterList(sender: UIBarButtonItem) {
        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(appSettings)
        }
    }

    // MARK: - Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        guard segue.identifier == "showDetail",
              let navController = segue.destinationViewController as? UINavigationController,
              let detailViewController = navController.topViewController as? DetailViewController,
              let svc = self.splitViewController else { return }
        
        detailViewController.currentDate = NSDate().dayFromDate()
        detailViewController.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        if !(sender is NSDictionary) {
            if let path = self.tableView.indexPathForSelectedRow,
               let title = self.tableView.cellForRowAtIndexPath(path)?.textLabel?.text {
                detailViewController.currentParameter = Parameter(rawValue: title)
                detailViewController.navigationItem.title = title
            }
            
        } else {
            if let dict = sender as? NSDictionary,
                   value = dict["currentParamter"] as? String,
                   param = Parameter(rawValue: value) {
                    
                detailViewController.currentParameter = param
                detailViewController.navigationItem.title = param.rawValue
            }
        }
    }
}
