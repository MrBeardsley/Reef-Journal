//
//  DetailViewController.swift
//  Reef Journal
//
//  Created by Chris Harding on 6/30/14.
//  Copyright (c) 2014 Christopher Harding. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var detailNavigationItem: UINavigationItem
    @IBOutlet var dateField: UILabel

    override func viewDidLoad() {
        let today = NSDate()
        var formatter = NSDateFormatter()
        formatter.formatterBehavior = .BehaviorDefault
        formatter.dateFormat = "MMMM dd ',' yyyy"

        if let dateString = formatter.stringFromDate(today) {
            self.dateField.text = dateString
        }
    }
}