//
//  ParametersListData.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/2/16
//  Copyright © 2016 Epic Kiwi Interactive
//

import UIKit
import CoreData

class ParameterListData: NSObject {
    
    // MARK: - Private Properties
    
    private let dateFormat = "MMMM dd ',' yyyy"
    private let dateFormatter = NSDateFormatter()
    
    // MARK: - Init/Deinit
    
    override init() {
        super.init()
        dateFormatter.dateFormat = self.dateFormat
    }
    
    // MARK: - Private Functions
    
    private func latestMeasurementForParameter(param: Parameter) -> Measurement? {
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter = %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
        fetchRequest.fetchLimit = 1
        
        var latest: Measurement? = nil
        
        do {
            if let
                results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Measurement],
                first = results.first {
                latest = first
            }
            
        }
        catch {
            let nserror = error as NSError
            NSLog("Error in fetch of measurements for enabled paramters: \(nserror), \(nserror.userInfo)")
        }
        
        return latest
    }
}

// MARK: - Data Model Conformance

extension ParameterListData: DataModel { }

// MARK: - Tableview Datasource methods

extension ParameterListData {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return enabledChemistryParameters.count
        case 1:
            return enabledNutrientParameters.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ParameterCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if let textLabel = cell.textLabel {
            
            switch indexPath.section {
            case 0:
                textLabel.text = enabledChemistryParameters[indexPath.row].rawValue
                
                if let aMeasurement = latestMeasurementForParameter(enabledChemistryParameters[indexPath.row]) {
                    
                    let decimalPlaces = aMeasurement.parameter.decimalPlaces
                    let format = "%." + String(decimalPlaces) + "f"
                    let dateString = dateFormatter.stringFromDate(aMeasurement.day)
                    
                    cell.detailTextLabel?.text = String(format: format, aMeasurement.convertedValue) + " " + aMeasurement.parameter.unitLabel + " on " + dateString
                }
                else {
                    cell.detailTextLabel?.text = "No Measurement"
                }
                
            case 1:
                textLabel.text = enabledNutrientParameters[indexPath.row].rawValue
                
                if let aMeasurement = latestMeasurementForParameter(enabledNutrientParameters[indexPath.row]) {
                    let decimalPlaces = aMeasurement.parameter.decimalPlaces
                    let format = "%." + String(decimalPlaces) + "f"
                    let dateString = dateFormatter.stringFromDate(aMeasurement.day)
                    cell.detailTextLabel?.text = String(format: format, aMeasurement.convertedValue) + " " + aMeasurement.parameter.unitLabel + " on " + dateString
                }
                else {
                    cell.detailTextLabel?.text = "No Measurement"
                }
            default:
                textLabel.text = "Not found"
            }
        }
        
        return cell
    }
}

// MARK: - UITableView delegate Methods

extension ParameterListData {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

// MARK: - UIDataSourceModelAssociation conformance

extension ParameterListData: UIDataSourceModelAssociation {

    @objc func modelIdentifierForElementAtIndexPath(idx: NSIndexPath, inView view: UIView) -> String? {
        switch idx.section {
        case 0:
            return enabledChemistryParameters[idx.row].rawValue
            
        case 1:
            return enabledNutrientParameters[idx.row].rawValue
        
        default:
            return ""
        }
    }

    @objc func indexPathForElementWithModelIdentifier(identifier: String, inView view: UIView) -> NSIndexPath? {
        guard let param = Parameter(rawValue: identifier) else { return nil }
        
        if let index = enabledChemistryParameters.indexOf(param) {
            return NSIndexPath(forRow: index, inSection: 0)
        }
        
        if let index = enabledNutrientParameters.indexOf(param) {
            return NSIndexPath(forRow: index, inSection: 1)
        }
        
        return nil
    }
}

// MARK: - EnableParametersType Conformance

extension ParameterListData: EnabledParametersType { }
