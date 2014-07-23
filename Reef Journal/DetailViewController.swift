//
//  DetailViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

let keyboardOffset: CGFloat = 100.0

class DetailViewController: UIViewController {

    @IBOutlet weak var detailNavigationItem: UINavigationItem!
    @IBOutlet weak var valueTextLabel: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var inputTextField: UITextField!

    var measurementValue: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // These can be removed when changing to a slider instead of a text field
        ///////////////////////////////////////////
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)

        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        numberToolbar.items = [UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelNumberPad"),
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: "doneWithNumberPad")]
        numberToolbar.sizeToFit()
        inputTextField.inputAccessoryView = numberToolbar
        ///////////////////////////////////////////

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd ',' yyyy"

        if let dateString = dateFormatter.stringFromDate(NSDate()) {
            self.dateField.text = dateString
        }

        var valueString = NSMutableAttributedString(string: "420")

        valueTextLabel.attributedText = valueString
    }

    //FIXME: Temporary fix for showing the keyboard until the custom control is implemented
    func keyboardDidShow(notification: NSNotification) {
        //Assign new frame to your view
        let currentFrame = self.view.bounds
        self.view.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y - keyboardOffset, width: currentFrame.width, height: currentFrame.height + keyboardOffset)
        println(currentFrame)
        println(self.view.frame)
    }

    func keyboardDidHide(notification: NSNotification) {
        let currentFrame = self.view.bounds
        self.view.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y, width: currentFrame.width, height: currentFrame.height - keyboardOffset)
        println(currentFrame)
        println(self.view.frame)
    }

    func cancelNumberPad() {
        inputTextField.resignFirstResponder()
    }

    func doneWithNumberPad() {
        let numberFromTheKeyboard = inputTextField.text
        inputTextField.resignFirstResponder()
    }
}