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
    let appDelegate: AppDelegate
    let entityName = "Measurement"
    let format = "MMMM dd ',' yyyy"
    let dateFormatter: NSDateFormatter
    var parameterType: Parameter!

    // MARK: - Init/Deinit
    required init?(coder aDecoder: NSCoder) {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                    parameterType = self.firstEnabledParameter()

                }
            }
            else {
                // Use the first enabled Parameter
                parameterType = self.firstEnabledParameter()
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

        sliderView.slider.value = 0

        // Coredata fetch to find the most recent measurement
        if let type = self.navigationItem.title {
            let context = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: entityName)
            let predicate = NSPredicate(format: "parameter = %@", argumentArray: [type])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
            fetchRequest.fetchLimit = 1

            do {
                let results = try context.executeFetchRequest(fetchRequest)
                if let aMeasurement = results.last as? Measurement {
                    //let decimalPlaces = decimalPlacesForParameter(self.parameterType!)
                    //let numberFormat = "%." + String(decimalPlaces) + "f"
                    sliderView.slider.value = aMeasurement.value
                }
                else {
                    sliderView.slider.value = 0
                }
            }
            catch {

            }
        }
    }

//    override func viewWillDisappear(animated: Bool) {
//        if let parent = delegate {
//            parent.refreshData()
//        }
//    }

    // MARK: - Interface Responders
    @IBAction func pickerDidChange(sender: UIDatePicker) {

        self.dateField.text = dateFormatter.stringFromDate(sender.date)


        if let aMeasurement = self.measurementForDate(self.datePicker.date) {
            sliderView.slider.value = aMeasurement.value
        }
        else {
            sliderView.slider.value = 0
        }
    }

    func saveMeasurement() {
        print("Measurement Saved")
    }

    func preferencesDidChange(notification: NSNotification?) {
        print("Reloaded preferences in Detail view Controller")
    }

    func valueChanged(slider: CircularSlider){
        // Do something with the value...
        print("Slider value: \(slider.value)")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let graphController = segue.destinationViewController as? GraphViewController {
            graphController.detailController = self
        }
    }
}

// MARK: - Private Functions
private extension DetailViewController {
    func measurementForDate(date: NSDate) -> Measurement? {
        let day = self.dayFromDate(date)
        let type = self.navigationItem.title!
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "parameter == %@ AND day == %@", argumentArray: [type, day])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.executeFetchRequest(fetchRequest)
            if let aMeasurement = results.last as? Measurement {
                return aMeasurement
            }
        }
        catch {

        }

        return nil
    }

    func dayFromDate(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: date)
        return calendar.dateFromComponents(components)!
    }

    func firstEnabledParameter() -> Parameter {

        return Parameter.Salinity
    }
}
