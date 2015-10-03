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

    @IBOutlet weak var detailNavigationItem: UINavigationItem!
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

        if parameterType == nil {
            //detailNavigationItem?.leftBarButtonItem?.title = "Parameters"
            
            if let defaultsString = userDefaults.stringForKey("LastParameter") {
                if let parameterFromDefaults = Parameter(rawValue: defaultsString) {
                    parameterType = parameterFromDefaults
                    self.navigationItem.title = parameterType!.rawValue
                }
                else {
                    parameterType = dataAccess.firstEnabledParameter()

                }
            }
            else {
                // Use the first enabled Parameter
                parameterType = dataAccess.firstEnabledParameter()
            }
        }
        else {
            userDefaults.setObject(parameterType!.rawValue, forKey: "LastParameter")
        }

        // Setup the controls
        let today = NSDate()
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

    // MARK: - Interface Actions

    @IBAction func pickerDidChange(sender: UIDatePicker) {
        guard let type = self.parameterType else { return }
        
        if let aMeasurement = dataAccess.measurementForDate(self.datePicker.date.dayFromDate(), param: type) {
            self.currentMeasurement = aMeasurement
            slider.value = aMeasurement.value
        }
        else {
            slider.value = slider.minValue
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
        guard let type = self.parameterType else { return }
        
        dataAccess.deleteMeasurementOnDay(currentMeasurement.day, param: self.parameterType)
        self.measurements = dataAccess.measurementsForParameter(self.parameterType)
        
        if self.measurements.count == 0 {
            self.deleteItem.enabled = false
            self.nextItem.enabled = false
            self.previousItem.enabled = false
            slider.value = slider.minValue
        }
        else {
            // get current day get the next latest measurement
            let today = datePicker.date.dayFromDate()
            
            for measurement in self.measurements {
                if measurement.day < today.timeIntervalSinceReferenceDate {
                    let date = NSDate(timeIntervalSinceReferenceDate: measurement.day)
                    datePicker.setDate(date, animated: true)
                    if let previousMeasurement = dataAccess.measurementForDate(date, param: type) {
                        slider.value = previousMeasurement.value
                        self.currentMeasurement = previousMeasurement
                    }
                    break
                }
            }
        }
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


    func preferencesDidChange(notification: NSNotification?) {
        // print("Reloaded preferences in Detail view Controller")
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let graphController = segue.destinationViewController as? GraphViewController {
            graphController.detailController = self
        }
    }
    
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
    
    
}
