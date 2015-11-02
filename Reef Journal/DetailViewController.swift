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
    @IBOutlet weak var splitController: UISplitViewController!

    // MARK: - Properties

    var parameterType: Parameter!
    var dataAccess: DataPersistence!
    var measurements: [Measurement]
    var currentMeasurement: Measurement?
    var emptyLabel: UILabel? = nil
    var settingsButton: UIButton? = nil
    let dateFormatter = NSDateFormatter()

    // MARK: - Init/Deinit

    required init?(coder aDecoder: NSCoder) {
        self.measurements = [Measurement]()
        super.init(coder: aDecoder)
    }

    // MARK: - View Management

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: "PreferencesChanged", object:nil)
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // If the paramterType is nil, it is because we are on an iPad and this view controller was loaded directly without selecting
        // it from the parameter list.
        if self.parameterType == nil {
            
            if let svc = self.splitViewController {
                if self.navigationItem.leftBarButtonItem == nil {
                    self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
                    
                }
            }
            
            if let
                defaultsString = userDefaults.stringForKey("LastParameter"),
                parameterFromDefaults = Parameter(rawValue: defaultsString)
                where defaultsParameterList().contains(defaultsString)      {
                    parameterType = parameterFromDefaults
                    self.navigationItem.title = defaultsString
            }
            else {
                changeToNewParameter()
                return
            }
        }
        
        if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular &&
            self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                
            if let splitController = self.splitViewController {
                splitController.preferredPrimaryColumnWidthFraction = 0.2
            }
        }
        
        setupControls()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        guard let type = self.parameterType else { return }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(type.rawValue, forKey: "LastParameter")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let parameterType = self.parameterType else { return }

        slider.layoutControl()

        if let lastValue = dataAccess.lastMeasurementValueForParameter(parameterType) {
            slider.value = lastValue.convertedMeasurementValue
            self.currentMeasurement = lastValue
        }
        else {
            slider.value = slider.minValue
        }
    }
    
    override func traitCollectionDidChange( previousTraitCollection: UITraitCollection?) {
        guard let splitController = self.splitViewController else { return }
        guard let mainWindow = self.view.window else { return }
        
        let traits = mainWindow.traitCollection
        
        // These traits signify and iPhone 6 Plus screen in landscape mode. In this instance we shrink the width of the parameter list in order to have enough room for the other controls.
        if traits.horizontalSizeClass == UIUserInterfaceSizeClass.Regular &&
            traits.verticalSizeClass == UIUserInterfaceSizeClass.Compact         {
                splitController.preferredPrimaryColumnWidthFraction = 0.2
        }
    }

    // MARK: - Interface Actions

    @IBAction func pickerDidChange(sender: UIDatePicker) {
        guard let type = self.parameterType else { return }
        
        if let aMeasurement = dataAccess.measurementForDate(self.datePicker.date.dayFromDate(), param: type) {
            self.currentMeasurement = aMeasurement
            slider.value = aMeasurement.convertedMeasurementValue
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
        self.currentMeasurement = dataAccess.measurementForDate(datePicker.date.dayFromDate(), param: type)
        
        NSNotificationCenter.defaultCenter().postNotificationName("SavedValue", object: nil)
    }

    @IBAction func deleteCurrentMeasurement(sender: UIBarButtonItem) {
        guard let currentMeasurement = self.currentMeasurement else { return }
        
        dataAccess.deleteMeasurementOnDay(currentMeasurement.day, param: self.parameterType)
        self.measurements = dataAccess.measurementsForParameter(self.parameterType)
        
        NSNotificationCenter.defaultCenter().postNotificationName("SavedValue", object: nil)
        
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
                    slider.value = data.convertedMeasurementValue
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
                    slider.value = data.convertedMeasurementValue
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
    
    func showSettings() -> Void {
        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(appSettings)
        }
    }


    // MARK: - Notification Handlers

    func preferencesDidChange(notification: NSNotification?) {
        // All parameters were previously disabled, but now we need to switch to a newly enabled one.
        guard parameterType != nil else {
            changeToNewParameter()
            return
        }
        
        // The parameter we were previously viewing might have been disabled. If so we need to switch to another parameter
        guard self.defaultsParameterList().contains(parameterType.rawValue) else {
            // Handle changing to another parameter
            changeToNewParameter()
            return
        }
        
        // One of the units might have changed, so we need to re-setup the controls to account for the differences when a value is converted.
        setupControls()
    }
    
    // MARK: - Seque
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "ShowGraph" {
            if let graphViewController = segue.destinationViewController as? GraphViewController,
               let svc = self.splitViewController {
                graphViewController.parameterType = self.parameterType
                graphViewController.dataAccess = self.dataAccess
                graphViewController.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
                graphViewController.navigationItem.leftItemsSupplementBackButton = true
            }
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
        guard self.emptyLabel == nil else { return }
        guard self.settingsButton == nil else { return }
        
        // Remove existing controls
        self.datePicker.hidden = true
        self.slider.hidden = true
        self.toolbar.hidden = true
        self.navigationItem.title = ""
        
        // Make sure the parameter type is removed
        self.parameterType = nil

        // Add some text and a button to settings explaining to the user what they should do.
        let label = UILabel()
        label.text = "You have disabled all parameters. Please enable some parmaters in Settings to track your measurements."
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
        // Add the button
        let button = UIButton()
        button.addTarget(self, action: Selector("showSettings"), forControlEvents: .TouchUpInside)
        button.setTitle("Settings", forState: .Normal)
        button.setTitleColor(self.view.tintColor, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        // Position and size the label
        let horizontalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(verticalConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 338)
        self.view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 75)
        self.view.addConstraint(heightConstraint)
        
        // Position and size the button
        let buttonWidth = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 67)
        self.view.addConstraint(buttonWidth)
        
        let buttonHeight = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 34)
        self.view.addConstraint(buttonHeight)
        
        let hButtonConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(hButtonConstraint)
        
        let vButtonConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: label, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8)
        self.view.addConstraint(vButtonConstraint)
        
        
        self.emptyLabel = label
        self.settingsButton = button
        
    }
    
    private func setupControls() -> Void {
        guard let parameterType = self.parameterType else { return }
        
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
            nextItem.enabled = false
            slider.value = slider.minValue
        }
        
        if let lastValue = dataAccess.measurementForDate(today, param: parameterType) {
            slider.value = lastValue.convertedMeasurementValue
            self.currentMeasurement = lastValue
        }
        
        if pastMeasurementsExist(today.timeIntervalSinceReferenceDate) {
            previousItem.enabled = true
        }
        else {
            previousItem.enabled = false
        }
        
        nextItem.enabled = false
    }
    
    private func changeToNewParameter() -> Void {
        guard let firstEnabledParameter = firstEnabledParameter() else {
            displayEmptyParameterView()
            return
        }
        
        if self.emptyLabel != nil {
            self.emptyLabel?.removeFromSuperview()
            self.emptyLabel = nil
        }
        
        if self.settingsButton != nil {
            self.settingsButton?.removeFromSuperview()
            self.settingsButton = nil
        }
        
        self.datePicker.hidden = false
        self.slider.hidden = false
        self.toolbar.hidden = false
        
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
        
        self.navigationItem.title = firstEnabledParameter
        setupControls()
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
