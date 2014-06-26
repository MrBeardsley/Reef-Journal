//
//  FirstViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 6/10/14.
//  Copyright (c) 2014 Christopher Harding. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet var dateLabel: UILabel
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        var formatter = NSDateFormatter()
//        formatter.dateFormat = "MMM dd, yyyy"
//        dateLabel.text = formatter.stringFromDate(NSDate.date())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

