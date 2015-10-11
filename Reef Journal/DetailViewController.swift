//
//  DetailViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    // MARK: - Interface Outlets

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var slider: CircularSlider!
    @IBOutlet weak var previousItem: UIBarButtonItem!
    @IBOutlet weak var nextItem: UIBarButtonItem!
    @IBOutlet weak var deleteItem: UIBarButtonItem!

    // MARK: - Properties

    var parameterType: Parameter!
    var dataAccess: DataPersistence!
    var measurements: [Measurement]
    var currentMeasurement: Measurement?
    let dateFormatter = NSDateFormatter()

    // MARK: - Init/Deinit

    required init?(coder aDecoder: NSCoder) {
        self.measurements = [Measurement]()
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: "PreferencesChanged", object:nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Management

    override func viewDidLoad() {
        super.viewDidLoad()

        // Determine if a parameter was previously saved
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // If the paramterType is nil, it is because we are on an iPad and this view controller was loaded directly without selecting
        // it from the parameter list.
        if parameterType == nil {
            
            // The back button is not set because there was no navigation to this view controller
            //detailNavigationItem?.leftBarButtonItem?.title = "Parameters"
            self.navigationItem.leftItemsSupplementBackButton = true
            
            if let
                defaultsString = userDefaults.stringForKey("LastParameter"),
                parameterFromDefaults = Parameter(rawValue: defaultsString)
                where defaultsParameterList().contains(defaultsString) {
                    parameterType = parameterFromDefaults
                    self.navigationItem.title = defaultsString
            }
            else {
                changeToNewParameter()
            }
        }
        else {
            userDefaults.setObject(parameterType!.rawValue, forKey: "LastParameter")
        }

        // Setup the controls
        let today = NSDate().dayFromDate()
        datePicker.setDate(today, animated: false)
        datePicker.maximumDate = today

        switch decimalPlacesForParameter(parameterType) {
        case 0:
            slider.valueFormat = DecimalFormat.None
        case 1:
            slider.valueFormat = DecimalFormat.One
        case 2:
            slider.valueFormat = DecimalFormat.Two
        case 3:
            slider.valueFormat = DecimalFormat.Three
        default:
            slider.valueFormat = DecimalFormat.None
        }

        let range = measurementRangeForParameterType(parameterType)

        slider.minValue = range.0
        slider.maxValue = range.1

        self.measurements = dataAccess.measurementsForParameter(self.parameterType)
        
        if self.measurements.count == 0 {
            previousItem.enabled = false
            deleteItem.enabled = false
        }
        
        if pastMeasurementsExist(today.timeIntervalSinceReferenceDate) {
            previousItem.enabled = true
        }
        else {
            previousItem.enabled = false
        }
        
        nextItem.enabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        slider.layoutControl()

        if let lastValue = dataAccess.lastMeasurementValueForParameter(parameterType) {
            slider.value = lastValue.value
            self.currentMeasurement = lastValue
        }
        else {
            slider.value = slider.minValue
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        if newCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular &&
            newCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                if let splitController = self.splitViewController {
                    splitController.preferredPrimaryColumnWidthFraction = 0.2
                }
        }
    }

    // MARK: - Interface Actions

    @IBAction func pickerDidChange(sender: UIDatePicker) {
        guard let type = self.parameterType else { return }
        
        if let aMeasurement = dataAccess.measurementForDate(self.datePicker.date.dayFromDate(), param: type) {
            self.currentMeasurement = aMeasurement
            slider.value = aMeasurement.value
            deleteItem.enabled = true
        }
        else {
            slider.value = slider.minValue
            deleteItem.enabled = false
        }
        
        if pastMeasurementsExist(datePicker.date.dayFromDate().timeIntervalSinceReferenceDate) {
            previousItem.enabled = true
        }
        else {
            previousItem.enabled = false
        }
        
        if futureMeasurementsExist(datePicker.date.dayFromDate().timeIntervalSinceReferenceDate) {
            nextItem.enabled = true
        }
        else {
            nextItem.enabled = false
        }
    }

    @IBAction func sliderDidChange(sender: CircularSlider) {
        guard let type = self.parameterType else { return }

        dataAccess.saveMeasurement(slider.value, date: datePicker.date.dayFromDate(), param: type)
        self.measurements = dataAccess.measurementsForParameter(type)
        
        self.deleteItem.enabled = true
    }

    @IBAction func deleteCurrentMeasurement(sender: UIBarButtonItem) {
        guard let currentMeasurement = self.currentMeasurement else { return }
        
        dataAccess.deleteMeasurementOnDay(currentMeasurement.day, param: self.parameterType)
        self.measurements = dataAccess.measurementsForParameter(self.parameterType)
        
        if pastMeasurementsExist(datePicker.date.dayFromDate().timeIntervalSinceReferenceDate) {
            self.loadPreviousMeasurement(previousItem)
            return
        }
        
        if futureMeasurementsExist(datePicker.date.dayFromDate().timeIntervalSinceReferenceDate) {
            self.loadNextMeasurement(nextItem)
            return
        }
        
        self.deleteItem.enabled = false
        self.nextItem.enabled = false
        self.previousItem.enabled = false
        slider.value = slider.minValue
        
    }

    @IBAction func loadPreviousMeasurement(sender: UIBarButtonItem) {
        let currentDay = datePicker.date.dayFromDate().timeIntervalSinceReferenceDate
        
        guard let type = self.parameterType else { return }
        guard pastMeasurementsExist(currentDay) else { return }
        
        for measurement in self.measurements {
            
            if measurement.day < currentDay {
                if let data = dataAccess.measurementForDate(NSDate(timeIntervalSinceReferenceDate: measurement.day), param: type) {
                    datePicker.setDate(NSDate(timeIntervalSinceReferenceDate: measurement.day), animated: true)
                    slider.value = data.value
                    deleteItem.enabled = true
                    self.currentMeasurement = data
                    
                    if pastMeasurementsExist(measurement.day) {
                        previousItem.enabled = true
                    }
                    else {
                        previousItem.enabled = false
                    }
                    
                    if futureMeasurementsExist(measurement.day) {
                        nextItem.enabled = true
                    }
                    else {
                        nextItem.enabled = false
                    }
                    
                }
                
                break
            }
        }
    }

    @IBAction func loadNextMeasurement(sender: UIBarButtonItem) {
        let currentDay = datePicker.date.dayFromDate().timeIntervalSinceReferenceDate
        
        guard let type = self.parameterType else { return }
        guard futureMeasurementsExist(currentDay) else { return }
        
        for measurement in self.measurements.reverse() {
            if measurement.day > currentDay {
                if let data = dataAccess.measurementForDate(NSDate(timeIntervalSinceReferenceDate: measurement.day), param: type) {
                    datePicker.setDate(NSDate(timeIntervalSinceReferenceDate: measurement.day), animated: true)
                    slider.value = data.value
                    deleteItem.enabled = true
                    self.currentMeasurement = data
                    
                    if pastMeasurementsExist(measurement.day) {
                        previousItem.enabled = true
                    }
                    else {
                        previousItem.enabled = false
                    }
                    
                    if futureMeasurementsExist(measurement.day) {
                        nextItem.enabled = true
                    }
                    else {
                        nextItem.enabled = false
                    }
                }
                
                break
            }
        }
    }

    // MARK: - Notification Handlers

    func preferencesDidChange(notification: NSNotification?) {
        let defaultParameterList = self.defaultsParameterList()
        
        guard defaultParameterList.contains(parameterType.rawValue) else {
            // Handle changing to another parameter
            changeToNewParameter()
            return
        }
    }
    
    // MARK: - Private Methods
    
    private func pastMeasurementsExist(day: NSTimeInterval) -> Bool {
        guard !self.measurements.isEmpty else { return false }
        
        for measurement in self.measurements {
            if measurement.day < day {
                return true
            }
        }
        
        return false
    }
    
    private func futureMeasurementsExist(day: NSTimeInterval) -> Bool {
        guard !self.measurements.isEmpty else { return false }
        
        for measurement in self.measurements {
            if measurement.day > day {
                return true
            }
        }
        
        return false
    }
    
    private func displayEmptyParameterView() -> Void {
        // Remove existing controls
        self.datePicker.removeFromSuperview()
        self.slider.removeFromSuperview()
        self.toolbar.removeFromSuperview()
        self.navigationItem.title = ""
        // Place new view
        print("add new view")
    }
    
    private func changeToNewParameter() -> Void {
        guard let firstEnabledParameter = firstEnabledParameter() else {
            displayEmptyParameterView()
            return
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let
            defaultsString = userDefaults.stringForKey("LastParameter"),
            parameterFromDefaults = Parameter(rawValue: defaultsString)
            where defaultsParameterList().contains(defaultsString)      {
                
                self.parameterType = parameterFromDefaults
        }
        else {
            self.parameterType = Parameter(rawValue: firstEnabledParameter)
        }
        
        
        // Setup the controls
        self.navigationItem.title = firstEnabledParameter
        
        let today = NSDate().dayFromDate()
        datePicker.setDate(today, animated: false)
        datePicker.maximumDate = today
        
        switch decimalPlacesForParameter(parameterType) {
        case 0:
            slider.valueFormat = DecimalFormat.None
        case 1:
            slider.valueFormat = DecimalFormat.One
        case 2:
            slider.valueFormat = DecimalFormat.Two
        case 3:
            slider.valueFormat = DecimalFormat.Three
        default:
            slider.valueFormat = DecimalFormat.None
        }
        
        let range = measurementRangeForParameterType(self.parameterType)
        
        slider.minValue = range.0
        slider.maxValue = range.1
        
        self.measurements = dataAccess.measurementsForParameter(self.parameterType)
        
        if self.measurements.count == 0 {
            previousItem.enabled = false
            deleteItem.enabled = false
        }
        
        if pastMeasurementsExist(today.timeIntervalSinceReferenceDate) {
            previousItem.enabled = true
        }
        else {
            previousItem.enabled = false
        }
        
        nextItem.enabled = false
        
        userDefaults.setObject(parameterType!.rawValue, forKey: "LastParameter")
    }
    
    private func defaultsParameterList() -> [String] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var defaultParameterList = [String]()
        
        for item in chemistryParameters {
            if userDefaults.boolForKey(item.rawValue) {
                defaultParameterList.append(parameterForPreference(item).rawValue)
            }
        }
        
        for item in nutrientParameters {
            if userDefaults.boolForKey(item.rawValue) {
                defaultParameterList.append(parameterForPreference(item).rawValue)
            }
        }
        
        return defaultParameterList
    }
    
    private func firstEnabledParameter() -> String? {
        return self.defaultsParameterList().first
    }
}
