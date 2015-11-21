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
        
        self.graphView.weekMeasurements = allMeasurements.filter {
            dateComponets.day = -7
            guard let startDate = calendar.dateByAddingComponents(dateComponets, toDate: today, options: .MatchStrictly) else { return true }
            let measurementDate = NSDate(timeIntervalSinceReferenceDate: $0.day)
            return measurementDate.compare(startDate) == .OrderedDescending
        }
        
        self.graphView.monthMeasurements = allMeasurements.filter {
            dateComponets.day = -28
            guard let startDate = calendar.dateByAddingComponents(dateComponets, toDate: today, options: .MatchStrictly) else { return true }
            let measurementDate = NSDate(timeIntervalSinceReferenceDate: $0.day)
            return measurementDate.compare(startDate) == .OrderedDescending
        }
        
        self.graphView.yearMeasurements = allMeasurements.filter {
            dateComponets.day = -365
            guard let startDate = calendar.dateByAddingComponents(dateComponets, toDate: today, options: .MatchStrictly) else { return true }
            let measurementDate = NSDate(timeIntervalSinceReferenceDate: $0.day)
            return measurementDate.compare(startDate) == .OrderedDescending
        }
        
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
        print("Time Scale Changed")
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
    }
}
