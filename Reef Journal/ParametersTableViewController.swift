//
//  ParametersTableViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


class ParametersTableViewController: UITableViewController {

    // MARK: - Properties

    var measurementsDataModel: MeasurementsData!
    var dataPersistence: DataPersistence!

    // MARK: - Private Properties

    private var chemistrySection: [String] = []
    private var nutrientsSection: [String] = []
    private var recentMeasurements: [String : Measurement]?
    private let dateFormat = "MMMM dd ',' yyyy"
    private let dateFormatter = NSDateFormatter()

    // MARK: - Init/Deinit

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dateFormatter.dateFormat = self.dateFormat
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.measurementsDataModel = MeasurementsData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: NSUserDefaultsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView:", name: "SavedValue", object:nil)
    }

    override func viewWillAppear(animated: Bool) {
        guard let svc = self.splitViewController else {
            super.viewWillAppear(animated)
            return
        }
        
        self.clearsSelectionOnViewWillAppear = svc.collapsed
        reloadTableView(nil)
        
        super.viewWillAppear(animated)
    }

    // MARK: - Reloading the data in the table view

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
        
        recentMeasurements = measurementsDataModel.mostRecentMeasurements()
        tableView?.reloadData()
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
                detailViewController.measurementsDataModel = measurementsDataModel
                detailViewController.navigationItem.title = title
                detailViewController.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

// MARK: - Tableview Datasource methods
    
extension ParametersTableViewController {
    
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
        
        if let textLabel = cell.textLabel {
            
            switch indexPath.section {
            case 0:
                let parameter = Parameter(rawValue: chemistrySection[indexPath.row])!
                textLabel.text = chemistrySection[indexPath.row]
                
                if let aMeasurement = recentMeasurements?[chemistrySection[indexPath.row]] {
                    
                    let decimalPlaces = decimalPlacesForParameter(parameter)
                    let format = "%." + String(decimalPlaces) + "f"
                    let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: aMeasurement.day))
                    
                    cell.detailTextLabel?.text = String(format: format, aMeasurement.convertedMeasurementValue) + " " + unitLabelForParameterType(parameter) + " on " + dateString
                }
                else {
                    cell.detailTextLabel?.text = "No Measurement"
                }
                
            case 1:
                let parameter = Parameter(rawValue: nutrientsSection[indexPath.row])!
                textLabel.text = nutrientsSection[indexPath.row]

                if let aMeasurement = recentMeasurements?[nutrientsSection[indexPath.row]] {
                    let decimalPlaces = decimalPlacesForParameter(parameter)
                    let format = "%." + String(decimalPlaces) + "f"
                    let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: aMeasurement.day))
                    cell.detailTextLabel?.text = String(format: format, aMeasurement.convertedMeasurementValue) + " " + unitLabelForParameterType(parameter) + " on " + dateString
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

extension ParametersTableViewController {

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
    
    @IBAction func editParameterList(sender: UIBarButtonItem) {
        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(appSettings)
        }
    }
}

// MARK: - State Restoration

extension ParametersTableViewController {
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
    }
}
