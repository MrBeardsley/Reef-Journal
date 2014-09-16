//
//  DetailViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit
import CoreData

let keyboardOffset: CGFloat = 100.0

class DetailViewController: UIViewController {

    // MARK: - Interface Outlets
    @IBOutlet weak var detailNavigationItem: UINavigationItem!
    @IBOutlet weak var valueTextLabel: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    // MARK: - Class Properties
    let appDelegate: AppDelegate
    let entityName = "Measurement"
    let format = "MMMM dd ',' yyyy"
    let dateFormatter: NSDateFormatter
    var parameterType: Parameter?
    var delegate: ParentControllerDelegate?
    lazy var valueFormat: String = {

        if (parameterTypeDisplaysDecimal(self.parameterType!)){
            return "%.1f"
        }
        else {
            return "%.0f"
        }
        }()

    // MARK: - Init/Deinit
    required init(coder aDecoder: NSCoder) {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Management
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the controls
        let today = NSDate()
        self.dateField.text = dateFormatter.stringFromDate(today)


        datePicker.setDate(today, animated: false)
        datePicker.maximumDate = NSDate()
        valueTextLabel.textColor = self.view.tintColor
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        numberToolbar.items = [UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelNumberPad"),
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: "doneWithNumberPad")]
        numberToolbar.sizeToFit()
        inputTextField.inputAccessoryView = numberToolbar

        if parameterTypeDisplaysDecimal(self.parameterType!) {
            inputTextField.keyboardType = .DecimalPad
        }
        else {
            inputTextField.keyboardType = .NumberPad
        }

        // Coredata fetch to find the most recent measurement
        let type: NSString = self.navigationItem.title!
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "type = %@", argumentArray: [type])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
        fetchRequest.fetchLimit = 1

        var error: NSError?
        if let results = context?.executeFetchRequest(fetchRequest, error: &error) {
            if let aMeasurement = results.last as? Measurement {
                let decimalPlaces = decimalPlacesForParameter(self.parameterType!)
                let format = "%." + String(decimalPlaces) + "f"
                valueTextLabel.text = NSString(format: format, aMeasurement.value) + " " + unitLabelForParameterType(self.parameterType!)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        if let parent = delegate {
            parent.refreshData()
        }
    }

    // MARK: - Interface Responders
    @IBAction func pickerDidChange(sender: UIDatePicker) {


        self.dateField.text = dateFormatter.stringFromDate(sender.date)


        if let aMeasurement = self.measurementForDate(self.datePicker.date) {
            valueTextLabel.text = NSString(format: valueFormat, aMeasurement.value)
        }
        else {
            valueTextLabel.text = "No Value"
        }
    }

    func keyboardDidShow(notification: NSNotification) {

        //Assign new frame to your view
        let currentFrame = self.view.bounds
        self.view.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y - keyboardOffset, width: currentFrame.width, height: currentFrame.height + keyboardOffset)
    }

    func keyboardDidHide(notification: NSNotification) {
        let currentFrame = self.view.bounds
        self.view.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y, width: currentFrame.width, height: currentFrame.height - keyboardOffset)
    }

    func cancelNumberPad() {
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
    }

    func doneWithNumberPad() {
        let decimalPlaces = decimalPlacesForParameter(self.parameterType!)
        let format = "%." + String(decimalPlaces) + "f"
        valueTextLabel.text = inputTextField.text + " " + unitLabelForParameterType(self.parameterType!)

        if let aMeasurement = self.measurementForDate(self.datePicker.date) {
            aMeasurement.value = NSString(string: valueTextLabel.text!).doubleValue
        }
        else {
            let newMeasurement: Measurement = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: appDelegate.managedObjectContext!) as Measurement
            newMeasurement.value = NSString(string: valueTextLabel.text!).doubleValue
            newMeasurement.type = self.navigationItem.title!
            newMeasurement.day = self.dayFromDate(self.datePicker.date).timeIntervalSinceReferenceDate
        }

        appDelegate.saveContext()

        inputTextField.text = ""
        inputTextField.resignFirstResponder()
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
        let type: NSString = self.navigationItem.title!
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "type == %@ AND day == %@", argumentArray: [type, day])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        var error: NSError?
        if let results = context?.executeFetchRequest(fetchRequest, error: &error) {
            if let aMeasurement = results.last as? Measurement {
                return aMeasurement
            }
        }

        return nil
    }

    func dayFromDate(date: NSDate) -> NSDate {
        let flags = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(flags, fromDate: date)
        return calendar.dateFromComponents(components)!
    }
}
