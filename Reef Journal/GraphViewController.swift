//
//  GraphViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit
import CoreData


class GraphViewController: UIViewController {

    // MARK: - Interface Outlets
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var minField: UILabel!
    @IBOutlet weak var maxField: UILabel!
    @IBOutlet weak var aveField: UILabel!

    // MARK: - Properties
    let appDelegate: AppDelegate
    let entityName = "Measurement"
    var detailController: DetailViewController!

    // MARK: - Init/Deinit
    required init?(coder aDecoder: NSCoder) {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: "PreferencesChanged", object:nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parent = detailController {

            let type = parent.navigationItem.title!
            let context = appDelegate.managedObjectContext

            if let parameterType = Parameter(rawValue: type as String) {
                graphView.parameterType = parameterType
            }
            else
            {
                graphView.parameterType = Parameter.Alkalinity
            }

            let fetchRequest = NSFetchRequest(entityName: entityName)
            let predicate = NSPredicate(format: "type = %@", argumentArray: [type])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true)]


            do {
                let results = try context.executeFetchRequest(fetchRequest)
                for item in results {
                    if let aMeasurement = item as? Measurement {
                        graphView.dataPoints.append((NSDate(timeIntervalSince1970: aMeasurement.day), aMeasurement.value))
                    }
                }

                if !results.isEmpty {
                    let minimum = graphView.dataPoints.reduce(Double.infinity, combine: { min($0, $1.1) })
                    let maximum = graphView.dataPoints.reduce(Double.quietNaN, combine: { max($0, $1.1) })
                    let sum = graphView.dataPoints.reduce(0.0, combine: { $0 + $1.1})
                    var format: String
                    if let parameterType = Parameter(rawValue: type as String) {
                        let decimalPlaces = decimalPlacesForParameter(parameterType)
                        format = "%." + String(decimalPlaces) + "f"
                    }
                    else
                    {
                        format = "%.2f"
                    }

                    minField.text = String(format: format, minimum)
                    maxField.text = String(format: format, maximum)
                    aveField.text = String(format: format, sum / Double(results.count))

                    graphView.maxValue = CGFloat(maximum)
                }
                else {
                    minField.text = "No data entered"
                    maxField.text = "No data entered"
                    aveField.text = "No data entered"
                }
            }
            catch {

            }
        }
    }

    func preferencesDidChange(notification: NSNotification?) {
        print("Reload the graph in graph view Controller")
    }
}
