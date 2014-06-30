//
//  ParametersTableViewController.swift
//  Reef Journal
//
//  Created by Chris Harding on 6/27/14.
//  Copyright (c) 2014 Christopher Harding. All rights reserved.
//

import UIKit

class ParametersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let chemistryParameters = ["Salinity","Alkalinity", "Calcium", "Magnesium", "pH", "Strontium", "Potasium"]
    let nutrientParameters = ["Nitrate", "Phosphate", "Ammonia", "Nitrite" ]

    var chemistrySection: Array<String> = []
    var nutrientsSection: Array<String> = []

    @IBOutlet var tableView: UITableView

    override func awakeFromNib() {

        let userDefaults = NSUserDefaults.standardUserDefaults()

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

    ////////////////////////////////////////////////////////////////////////////////////
    // UITableiew Data Source Methods
    ////////////////////////////////////////////////////////////////////////////////////
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return chemistrySection.count
        case 1:
            return nutrientsSection.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {


        let cellIdentifier = "ParameterCell";
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? UITableViewCell {
            switch indexPath.section {
            case 0:
                cell.textLabel.text = chemistrySection[indexPath.row]
            case 1:
                cell.textLabel.text = nutrientsSection[indexPath.row]
            default:
                cell.textLabel.text = "Not found"
            }

            return cell
        }
        else {
            var newCell = UITableViewCell(style: .Value1, reuseIdentifier: cellIdentifier)
            newCell.textLabel.text = "Test 2"
            return newCell
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    // UITableView delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }

    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
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
