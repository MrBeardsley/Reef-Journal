//
//  GraphViewController.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


enum TimeScale {
    case Week
    case Month
    case Year
}

class GraphViewController: UIViewController {

    // MARK: - Interface Outlets
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var graphData: GraphData!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Properties
    
    var currentParameter: Parameter!
    var measurementDateModel = MeasurementsData()

    // MARK: - Init/Deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let param = self.currentParameter else { return }
        
        graphView.currentParameter = param
        graphData.currentParameter = param
        
        graphData.fetchMeasurementData()
        
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        graphView.drawLabels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        guard let svc = self.splitViewController else { return }
        svc.preferredDisplayMode = .Automatic
        
        super.viewWillDisappear(animated)
    }

    func preferencesDidChange(notification: NSNotification?) {
        graphData.fetchMeasurementData()
        graphView.drawLabels()
        graphView.setNeedsDisplay()
    }
    
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
        
        graphView.setNeedsDisplay()
        graphView.drawLabels()
    }
}

// MARK: - State Restoration

extension GraphViewController {
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        coder.encodeInteger(segmentControl.selectedSegmentIndex, forKey: "TimeScaleIndex")
        coder.encodeObject(currentParameter.rawValue, forKey: "CurrentParameter")
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        self.segmentControl.selectedSegmentIndex = coder.decodeIntegerForKey("TimeScaleIndex")
        switch segmentControl.selectedSegmentIndex {
        case 0:
            graphView.scale = .Week
            break
        case 1:
            graphView.scale = .Month
            break
        case 2:
            graphView.scale = .Year
            break
        default:
            graphView.scale = .Week
        }
        
        if let
            restoredParamter = coder.decodeObjectForKey("CurrentParameter") as? String,
            param = Parameter(rawValue: restoredParamter) {
                
            currentParameter = param
            graphView.currentParameter = param
            graphData.currentParameter = param
            graphData.fetchMeasurementData()
        }
    }
}


