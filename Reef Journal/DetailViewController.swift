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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd ',' yyyy"

        if let dateString = dateFormatter.stringFromDate(NSDate()) {
            self.dateField.text = dateString
        }
    }
}