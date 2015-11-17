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
    
    private enum TimeScale {
        case Week
        case Month
        case Year
    }

    // MARK: - Interface Outlets
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Properties
    var parameterType: Parameter!
    var dataModel: DataPersistence!
    
    // Mark: - Private Properties
    private var weekMeasurements = [Measurement]()
    private var monthMeasurements = [Measurement]()
    private var yearMeaturements = [Measurement]()
    private var scale: TimeScale

    // MARK: - Init/Deinit
    required init?(coder aDecoder: NSCoder) {
        scale = .Week
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
        
//        weekMeasurements = allMeasurements.filter(<#T##includeElement: (Measurement) throws -> Bool##(Measurement) throws -> Bool#>)
//        monthMeasurements = allMeasurements.filter(<#T##includeElement: (Measurement) throws -> Bool##(Measurement) throws -> Bool#>)
//        yearMeaturements = allMeasurements.filter(<#T##includeElement: (Measurement) throws -> Bool##(Measurement) throws -> Bool#>)
        
        let today = NSDate()
        
        print(allMeasurements)
        print(today)
        
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
            self.scale = .Week
        case 1:
            self.scale = .Month
        case 2:
            self.scale = .Year
        default:
            self.scale = .Week
        }
        
        print("Time Scale: \(self.scale)")
    }
}
