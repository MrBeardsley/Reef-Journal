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
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sliderView: CircularSliderView!

    // MARK: - Properties

    let format = "MMMM dd ',' yyyy"
    let dateFormatter: NSDateFormatter
    var parameterType: Parameter!
    var dataAccess: DataPersistence!

    // MARK: - Init/Deinit

    required init?(coder aDecoder: NSCoder) {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: "PreferencesChanged", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveMeasurement", name: "SaveMeasurement", object:nil)
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
        let today = NSDate()
        self.dateField.text = dateFormatter.stringFromDate(today)

        datePicker.setDate(today, animated: false)
        datePicker.maximumDate = NSDate()

        switch decimalPlacesForParameter(parameterType) {
        case 0:
            sliderView.slider.valueFormat = DecimalFormat.None
        case 1:
            sliderView.slider.valueFormat = DecimalFormat.One
        case 2:
            sliderView.slider.valueFormat = DecimalFormat.Two
        case 3:
            sliderView.slider.valueFormat = DecimalFormat.Three
        default:
            sliderView.slider.valueFormat = DecimalFormat.None
        }

        let range = measurementRangeForParameterType(parameterType)

        sliderView.slider.minValue = range.0
        sliderView.slider.maxValue = range.1

        if let lastValue = dataAccess.lastMeasurementValueForParameter(parameterType) {
            sliderView.slider.value = lastValue
        }
        else {
            sliderView.slider.value = range.0
        }
    }

    // MARK: - Interface Responders

    @IBAction func pickerDidChange(sender: UIDatePicker) {

        self.dateField.text = dateFormatter.stringFromDate(sender.date)


        if let aMeasurement = dataAccess.measurementForDate(self.datePicker.date, param: self.parameterType) {
            sliderView.slider.value = aMeasurement.value
        }
        else {
            sliderView.slider.value = 0
        }
    }

    func saveMeasurement() {
        guard let type = self.parameterType else {
            return
        }

        dataAccess.saveMeasurement(sliderView.slider.value, date: datePicker.date, param: type)
    }

    func preferencesDidChange(notification: NSNotification?) {
        // print("Reloaded preferences in Detail view Controller")
    }

    func valueChanged(slider: CircularSlider){
        // Do something with the value...
        // print("Slider value: \(slider.value)")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let graphController = segue.destinationViewController as? GraphViewController {
            graphController.detailController = self
        }
    }
}
