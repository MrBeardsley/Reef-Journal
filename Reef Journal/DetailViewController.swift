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

    @IBOutlet weak var detailNavigationItem: UINavigationItem!
    @IBOutlet weak var valueTextLabel: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    var currentValue: Double = 0
    let appDelegate: AppDelegate
    let entityName = "Measurement"

    required init(coder aDecoder: NSCoder!) {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        numberToolbar.items = [UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelNumberPad"),
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: "doneWithNumberPad")]
        numberToolbar.sizeToFit()
        inputTextField.inputAccessoryView = numberToolbar
        ///////////////////////////////////////////


        // Get the date in day only format for comparison
        let flags = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(flags, fromDate: NSDate())
        let today = calendar.dateFromComponents(components)

        // Coredata fetch to find the most recent measurement
        let type = self.navigationItem.title
        let context = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "type = %@", argumentArray: [type])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
        fetchRequest.fetchLimit = 1

        var error: NSError?
        if let results = context?.executeFetchRequest(fetchRequest, error: &error) {
            if let aMeasurement = results.last as? Measurement {
                let measurementComponents = calendar.components(flags, fromDate: NSDate(timeIntervalSince1970: aMeasurement.day))
                let measurementDay = calendar.dateFromComponents(measurementComponents)

                valueTextLabel.text = NSString(format: "%.2f", aMeasurement.value)
            }
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd ',' yyyy"

        if let dateString = dateFormatter.stringFromDate(NSDate()) {
            self.dateField.text = dateString
        }


        datePicker.setDate(NSDate(), animated: false)

        let tintColor = self.view.tintColor
        valueTextLabel.textColor = tintColor

    }

    @IBAction func pickerDidChange(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd ',' yyyy"

        if let dateString = dateFormatter.stringFromDate(sender.date) {
            self.dateField.text = dateString
        }
    }

    //FIXME: Temporary fix for showing the keyboard until the custom control is implemented
    func keyboardDidShow(notification: NSNotification) {
        // Get the current value displayed

        currentValue = NSString(string: valueTextLabel.text).doubleValue

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
        valueTextLabel.text = inputTextField.text
        currentValue = NSString(string: valueTextLabel.text).doubleValue

        let type = self.navigationItem.title
        let context = appDelegate.managedObjectContext
        let newMeasurement: Measurement = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as Measurement
        newMeasurement.value = currentValue
        newMeasurement.type = type
        newMeasurement.day = self.datePicker.date.timeIntervalSince1970

        appDelegate.saveContext()

        inputTextField.text = ""
        inputTextField.resignFirstResponder()
    }
}