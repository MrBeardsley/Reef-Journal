//
//  GraphViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit
import CoreData

enum TimeScale {
    case Week
    case Month
    case Year
}

class GraphViewController: UIViewController {
    
    

    // MARK: - Interface Outlets
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Properties
    var parameterType: Parameter!
    var dataModel: DataPersistence!

    // MARK: - Init/Deinit
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: "PreferencesChanged", object:nil)
    }

    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let model = self.dataModel else { return }
        guard let parameterType = self.parameterType else { return }
        
        let allMeasurements = model.measurementsForParameter(parameterType)
        let today = NSDate().dayFromDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponets = NSDateComponents()
        
        var weekly = [Double?]()
        var monthly = [Double?]()
        var yearly = [Double?]()
        
        for day in -365 ... 0 {
            let index = allMeasurements.indexOf {
                dateComponets.day = day
                guard let startDate = calendar.dateByAddingComponents(dateComponets, toDate: today, options: .MatchStrictly) else { return false }
                let measurementDate = NSDate(timeIntervalSinceReferenceDate: $0.day)
                return measurementDate.compare(startDate) == .OrderedSame
            }
            
            if let i = index {
                switch day {
                case -6...0:
                    weekly.append(allMeasurements[i].value)
                    monthly.append(allMeasurements[i].value)
                    yearly.append(allMeasurements[i].value)
                    break
                case -27...0:
                    monthly.append(allMeasurements[i].value)
                    yearly.append(allMeasurements[i].value)
                    break
                default:
                    yearly.append(allMeasurements[i].value)
                }
            }
            else {
                switch day {
                case -6...0:
                    weekly.append(nil)
                    monthly.append(nil)
                    yearly.append(nil)
                    break
                case -27...0:
                    monthly.append(nil)
                    yearly.append(nil)
                    break
                default:
                    yearly.append(nil)
                }
            }
        }
        
        
        
        self.graphView.weekMeasurements = weekly
        self.graphView.monthMeasurements = monthly
        self.graphView.yearMeasurements = yearly
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.graphView.scale = .Week
        case 1:
            self.graphView.scale = .Month
        case 2:
            self.graphView.scale = .Year
        default:
            self.graphView.scale = .Week
        }
        
        self.graphView.graphTitle.text = self.parameterType.rawValue
    }
    
    override func viewWillDisappear(animated: Bool) {
        guard let svc = self.splitViewController else { return }
        svc.preferredDisplayMode = .Automatic
        
        super.viewWillDisappear(animated)
    }

//    func preferencesDidChange(notification: NSNotification?) {
//        print("Reload the graph in graph view Controller")
//    }
    
    @IBAction func timeScaleChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.graphView.scale = .Week
        case 1:
            self.graphView.scale = .Month
        case 2:
            self.graphView.scale = .Year
        default:
            self.graphView.scale = .Week
        }
        
        self.graphView.setNeedsDisplay()
    }
}
