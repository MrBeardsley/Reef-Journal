//
//  ParametersListViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


class ParametersListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
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
        if segue.identifier == "showDetail" {
            if let path = self.tableView.indexPathForSelectedRow,
               let title = self.tableView.cellForRowAtIndexPath(path)?.textLabel?.text,
               let navController = segue.destinationViewController as? UINavigationController,
               let detailViewController = navController.topViewController as? DetailViewController,
               let svc = self.splitViewController   {
                detailViewController.currentParameter = Parameter(rawValue: title)
                detailViewController.currentDate = NSDate().dayFromDate()
                detailViewController.navigationItem.title = title
                detailViewController.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
