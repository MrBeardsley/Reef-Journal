//
//  ParametersTableViewController.swift
//  Reef Journal
//
//  Created by Chris Harding on 6/27/14.
//  Copyright (c) 2014 Christopher Harding. All rights reserved.
//

import UIKit

class ParametersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let chemistryParameterList: Array<String> = ["Salinity", "Alkalinity", "Calcium", "Magnesium"]
    let nutrientParameterList: Array<String> = ["Nitrate", "Phosphate"]

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return chemistryParameterList.count
        case 1:
            return nutrientParameterList.count
        default:
            return 0
        }
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {


        let cellIdentifier = "ParameterCell";
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? UITableViewCell {
            switch indexPath.section {
            case 0:
                cell.textLabel.text = chemistryParameterList[indexPath.row]
            case 1:
                cell.textLabel.text = nutrientParameterList[indexPath.row]
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

    // UITableView delegate Methods
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
