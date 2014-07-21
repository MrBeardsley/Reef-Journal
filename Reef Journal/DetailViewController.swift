//
//  DetailViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var detailNavigationItem: UINavigationItem
    @IBOutlet var valueTextLabel: UILabel
    @IBOutlet var dateField: UILabel

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd ',' yyyy"

        if let dateString = dateFormatter.stringFromDate(NSDate()) {
            self.dateField.text = dateString
        }

        var valueString = NSMutableAttributedString(string: "420")

        valueTextLabel.attributedText = valueString
    }
}