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
                    print(parameterType!.rawValue)
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
        datePicker.setDate(NSDate(), animated: false)
        datePicker.maximumDate = NSDate()

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
        print(measurements)
        
        if self.measurements.count == 0 {
            previousItem.enabled = false
            nextItem.enabled = false
            deleteItem.enabled = false
        }
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
        if let aMeasurement = dataAccess.measurementForDate(self.datePicker.date, param: self.parameterType) {
            slider.value = aMeasurement.value
        }
        else {
            slider.value = 0
        }
    }

    @IBAction func sliderDidChange(sender: CircularSlider) {
        guard let type = self.parameterType else { return }

        dataAccess.saveMeasurement(slider.value, date: datePicker.date, param: type)
        self.deleteItem.enabled = true
    }

    @IBAction func deleteCurrentMeasurement(sender: UIBarButtonItem) {
        guard let currentMeasurement = self.currentMeasurement else { return }
        
        dataAccess.deleteMeasurementOnDay(currentMeasurement.day, param: self.parameterType)
        self.measurements = dataAccess.measurementsForParameter(self.parameterType)
        
        if self.measurements.count == 0 {
            self.deleteItem.enabled = false
            slider.value = slider.minValue
        }
    }

    @IBAction func loadPreviousMeasurement(sender: UIBarButtonItem) {
        print("Load Previous Measurement")
    }

    @IBAction func loadNextMeasurement(sender: UIBarButtonItem) {
        print("Load Next Measurement")
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
}
