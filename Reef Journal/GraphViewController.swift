//
//  GraphViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit
import CoreData


class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var minField: UILabel!
    @IBOutlet weak var maxField: UILabel!
    @IBOutlet weak var aveField: UILabel!

    let appDelegate: AppDelegate
    let entityName = "Measurement"
    var detailController: DetailViewController?

    required init(coder aDecoder: NSCoder) {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {

        if let parent = detailController {

            let type = parent.navigationItem.title
            let context = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: entityName)
            let predicate = NSPredicate(format: "type = %@", argumentArray: [type])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
    
            var error: NSError?
            if let results = context?.executeFetchRequest(fetchRequest, error: &error) {

                for item in results {
                    if let aMeasurement = item as? Measurement {
                        graphView.dataPoints += [(NSDate(timeIntervalSinceReferenceDate: aMeasurement.day), aMeasurement.value)]
                    }
                }

                if !results.isEmpty {
                    let minimum = graphView.dataPoints.reduce(Double.infinity, combine: { min($0, $1.1) })
                    let maximum = graphView.dataPoints.reduce(Double.quietNaN, combine: { max($0, $1.1) })
                    let sum = graphView.dataPoints.reduce(0.0, combine: { $0 + $1.1})

                    minField.text = NSString(format: "%.2f", minimum)
                    maxField.text = NSString(format: "%.2f", maximum)
                    aveField.text = NSString(format: "%.2f", sum / Double(results.count))

                    graphView.maxValue = CGFloat(maximum)
                }
                else {
                    minField.text = "No data entered"
                    maxField.text = "No data entered"
                    aveField.text = "No data entered"
                }
            }
        }
    }
}
