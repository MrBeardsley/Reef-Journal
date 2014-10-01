//
//  ParametersTableViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit
import CoreData


class ParametersTableViewController: UITableViewController, ParentControllerDelegate {


    let entityName = "Measurement"
    let appDelegate: AppDelegate
    let chemistryParameters: [PreferenceIdentifier] = [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium]
    let nutrientParameters: [PreferenceIdentifier] = [.EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]

    var chemistrySection: [String] = []
    var nutrientsSection: [String] = []
    var recentMeasurements: [String : Double]?

    // MARK: - Init/Deinit
    required init(coder aDecoder: NSCoder) {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: NSUserDefaultsDidChangeNotification, object:nil)
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

        let userDefaults = NSUserDefaults.standardUserDefaults()
        chemistrySection = []
        nutrientsSection = []

        for item in chemistryParameters {
            if userDefaults.boolForKey(item.rawValue) {
                chemistrySection.append(parameterForPreference(item).rawValue)
            }
        }

        for item in nutrientParameters {
            if userDefaults.boolForKey(item.rawValue) {
                nutrientsSection.append(parameterForPreference(item).rawValue)
            }
        }

        recentMeasurements = self.mostRecentMeasurements()
        tableView?.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if let path = self.tableView.indexPathForSelectedRow() {
            if let title = self.tableView.cellForRowAtIndexPath(path)?.textLabel?.text {
                if let detailViewController = segue.destinationViewController as? DetailViewController {
                    detailViewController.parameterType = Parameter(rawValue: title)
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

        let cellIdentifier = "ParameterCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell

        switch indexPath.section {
        case 0:
            let parameter = Parameter(rawValue: chemistrySection[indexPath.row])!
            cell.textLabel?.text = chemistrySection[indexPath.row]

            if let value = recentMeasurements?[chemistrySection[indexPath.row]] {
                let decimalPlaces = decimalPlacesForParameter(parameter)
                let format = "%." + String(decimalPlaces) + "f"
                cell.detailTextLabel?.text = NSString(format: format, value) + " " + unitLabelForParameterType(parameter)
            }
            else {
                cell.detailTextLabel?.text = "No Measurement"
            }

        case 1:
            let parameter = Parameter(rawValue: nutrientsSection[indexPath.row])!
            cell.textLabel?.text = nutrientsSection[indexPath.row]
            if let value = recentMeasurements?[nutrientsSection[indexPath.row]] {
                let decimalPlaces = decimalPlacesForParameter(parameter)
                let format = "%." + String(decimalPlaces) + "f"
                cell.detailTextLabel?.text = NSString(format: format, value) + " " + unitLabelForParameterType(parameter)
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

        for item in parameterList {
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
