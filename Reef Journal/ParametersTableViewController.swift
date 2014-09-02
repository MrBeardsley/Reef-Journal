//
//  ParametersTableViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit
import CoreData

protocol ParentControllerDelegate {
    func refreshData()
}

class ParametersTableViewController: UITableViewController, ParentControllerDelegate {

    let chemistryParameters = ["Salinity","Alkalinity", "Calcium", "Magnesium", "pH", "Strontium", "Potasium"]
    let nutrientParameters = ["Nitrate", "Phosphate", "Ammonia", "Nitrite" ]
    let entityName = "Measurement"
    let appDelegate: AppDelegate

    var chemistrySection: Array<String> = []
    var nutrientsSection: Array<String> = []
    var recentMeasurements: [String : Double]?

    // MARK: - Init/Deinit
    required init(coder aDecoder: NSCoder) {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: "PreferencesChanged", object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Management
    override func viewDidLoad() {
        reloadTableView(nil)
    }


    // MARK: - Reloading the data in the table view
    func refreshData() {
        reloadTableView(nil)
    }

    func reloadTableView(aNotification: NSNotification?) {
        recentMeasurements = self.mostRecentMeasurements()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        chemistrySection = []
        nutrientsSection = []

        for item in chemistryParameters {
            if userDefaults.boolForKey(item) {
                chemistrySection.append(item)
            }
        }

        for item in nutrientParameters {
            if userDefaults.boolForKey(item) {
                nutrientsSection.append(item)
            }
        }

        tableView?.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if let path = self.tableView.indexPathForSelectedRow() {
            if let title = self.tableView.cellForRowAtIndexPath(path)?.textLabel?.text {
                if let detailViewController = segue.destinationViewController as? DetailViewController {
                    detailViewController.navigationItem.title = title
                    detailViewController.delegate = self
                }
            }
        }
    }

    // MARK: - Tableview Datasource methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return chemistrySection.count
        case 1:
            return nutrientsSection.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier = "ParameterCell";
        var cell: UITableViewCell

        if let tableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? UITableViewCell {
            cell = tableViewCell
        }
        else {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = chemistrySection[indexPath.row]
            if let value = recentMeasurements?[chemistrySection[indexPath.row]] {
                cell.detailTextLabel?.text = NSString(format: "%.2f", value)
            }
            else {
                cell.detailTextLabel?.text = "No Measurement"
            }

        case 1:
            cell.textLabel?.text = nutrientsSection[indexPath.row]
            if let value = recentMeasurements?[nutrientsSection[indexPath.row]] {
                cell.detailTextLabel?.text = NSString(format: "%.2f", value)
            }
            else {
                cell.detailTextLabel?.text = "No Measurement"
            }
        default:
            cell.textLabel?.text = "Not found"
        }

        return cell
    }

    // MARK: - UITableView delegate Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Chemistry"
        case 1:
            return "Nutrients"
        default:
            return "Error"
        }
    }
}

private extension ParametersTableViewController {
    func mostRecentMeasurements() -> [String : Double] {

        let context = appDelegate.managedObjectContext
        var recentMeasurements = [String : Double]()

        for item in appDelegate.parameterList {
            let fetchRequest = NSFetchRequest(entityName: entityName)
            let predicate = NSPredicate(format: "type = %@", argumentArray: [item])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
            fetchRequest.fetchLimit = 1

            var error: NSError?
            if let results = context?.executeFetchRequest(fetchRequest, error: &error) {
                if let aMeasurement = results.last as? Measurement {
                    recentMeasurements[aMeasurement.type] = aMeasurement.value
                }
            }
        }

        return recentMeasurements
    }
}
