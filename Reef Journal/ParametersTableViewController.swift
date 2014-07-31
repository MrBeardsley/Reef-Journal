//
//  ParametersTableViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class ParametersTableViewController: UITableViewController {

    let chemistryParameters = ["Salinity","Alkalinity", "Calcium", "Magnesium", "pH", "Strontium", "Potasium"]
    let nutrientParameters = ["Nitrate", "Phosphate", "Ammonia", "Nitrite" ]

    var chemistrySection: Array<String> = []
    var nutrientsSection: Array<String> = []

    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: "PreferencesChanged", object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        reloadTableView(nil)
    }

    func reloadTableView(aNotification: NSNotification?) {
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

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {

        let path = self.tableView.indexPathForSelectedRow()
        let title = self.tableView.cellForRowAtIndexPath(path).textLabel.text
        if let detailViewController = segue.destinationViewController as? DetailViewController {
            detailViewController.navigationItem.title = title
        }
    }

    // MARK: - Tableview Datasource methods
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return chemistrySection.count
        case 1:
            return nutrientsSection.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {

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
            cell.textLabel.text = chemistrySection[indexPath.row]
        case 1:
            cell.textLabel.text = nutrientsSection[indexPath.row]
        default:
            cell.textLabel.text = "Not found"
        }

        cell.detailTextLabel.text = "1.035"

        return cell
    }

    // MARK: - UITableView delegate Methods

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
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
