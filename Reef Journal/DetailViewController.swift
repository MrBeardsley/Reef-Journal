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
    var measurementsDataModel: DataPersistence!
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Management

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let svc = self.splitViewController else { return }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let today = NSDate().dayFromDate()
        datePicker.setDate(today, animated: false)
        datePicker.maximumDate = today

        // If the paramterType is nil, it is because we are on an iPad and this view controller was loaded directly without selecting
        // it from the parameter list.
        if self.parameterType == nil {
            
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
        
        // This is for the iPhone 6 Plus because it can start in landscape mode and needs to display
        // the control to show and hide the parameter list. 
        //
        // It also needs to be narrower in order to fit all the controls in landscape mode.
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true
        
        if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular &&
            self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                
            svc.preferredPrimaryColumnWidthFraction = 0.2
        }
        
        setupControls()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // This is necessary when returning from the graph view controller
        // When an iPad is in landscape mode the parameter list is hidden when presenting the 
        // graph view. The split view needs to be relaid out in order to take into acount the
        // parameter list being added back to the view.
        guard let svc = self.splitViewController else { return }
        
        svc.view.setNeedsLayout()
        svc.view.layoutIfNeeded()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let type = self.parameterType else { return }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(type.rawValue, forKey: "LastParameter")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let param = self.parameterType else { return }
        slider.layoutControl()
        
        
        if let current =  self.currentMeasurement {
            datePicker.setDate(NSDate(timeIntervalSinceReferenceDate: current.day), animated: false)
            slider.value = current.convertedMeasurementValue
        }
        else {
            if let lastValue = measurementsDataModel.measurementForDate(NSDate(), param: param) {
                slider.value = lastValue.convertedMeasurementValue
                self.currentMeasurement = lastValue
            }
            else {
                slider.value = slider.minValue
            }
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
        
        if let aMeasurement = measurementsDataModel.measurementForDate(self.datePicker.date.dayFromDate(), param: type) {
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

        measurementsDataModel.saveMeasurement(slider.value, date: datePicker.date.dayFromDate(), param: type)
        self.measurements = measurementsDataModel.measurementsForParameter(type)
        self.deleteItem.enabled = true
        self.currentMeasurement = measurementsDataModel.measurementForDate(datePicker.date.dayFromDate(), param: type)
        
        NSNotificationCenter.defaultCenter().postNotificationName("SavedValue", object: nil)
    }

    @IBAction func deleteCurrentMeasurement(sender: UIBarButtonItem) {
        guard let currentMeasurement = self.currentMeasurement else { return }
        
        measurementsDataModel.deleteMeasurementOnDay(currentMeasurement.day, param: self.parameterType)
        self.measurements = measurementsDataModel.measurementsForParameter(self.parameterType)
        
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
                if let data = measurementsDataModel.measurementForDate(NSDate(timeIntervalSinceReferenceDate: measurement.day), param: type) {
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
                if let data = measurementsDataModel.measurementForDate(NSDate(timeIntervalSinceReferenceDate: measurement.day), param: type) {
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
            if let graphViewController = segue.destinationViewController as? GraphViewController {
                graphViewController.parameterType = self.parameterType
                graphViewController.dataModel = self.measurementsDataModel
            }
                
            if let svc = self.splitViewController {
                svc.preferredDisplayMode = .PrimaryHidden
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
        guard let currentParameter = self.parameterType else { return }
        
        switch decimalPlacesForParameter(currentParameter) {
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
        
        let range = measurementRangeForParameterType(currentParameter)
        
        slider.minValue = range.0
        slider.maxValue = range.1
        
        self.measurements = measurementsDataModel.measurementsForParameter(currentParameter)
        
        if self.measurements.count == 0 {
            previousItem.enabled = false
            deleteItem.enabled = false
            nextItem.enabled = false
            slider.value = slider.minValue
        }
        
        let currentDate = datePicker.date
        
        if !measurementsDataModel.dateHasMeasurement(currentDate, param: currentParameter) {
            deleteItem.enabled = false
        }
        else {
            if let measurementValue = measurementsDataModel.measurementForDate(currentDate, param: currentParameter)?.convertedMeasurementValue{
                slider.value = measurementValue
            }
        }
        
        if pastMeasurementsExist(currentDate.timeIntervalSinceReferenceDate) {
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

// MARK: - State Restoration

extension DetailViewController {
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        guard let currentParam = self.parameterType else { return }
        
        coder.encodeObject(currentParam.rawValue, forKey: "CurrentParameter")
        coder.encodeObject(self.datePicker.date, forKey: "CurrentDate")
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        if let
            currentParameter = coder.decodeObjectForKey("CurrentParameter") as? String,
            currentDate = coder.decodeObjectForKey("CurrentDate") as? NSDate {
            self.parameterType = Parameter(rawValue: currentParameter)
            self.datePicker.setDate(currentDate, animated: false)
            self.navigationItem.title = self.parameterType.rawValue
            setupControls()
        }
    }
}
