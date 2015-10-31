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
    let entityName = "Measurement"
    var parameterType: Parameter!
    var dataAccess: DataPersistence!
    private var scale: TimeScale

    // MARK: - Init/Deinit
    required init?(coder aDecoder: NSCoder) {
        scale = .Week
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesDidChange:", name: "PreferencesChanged", object:nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func preferencesDidChange(notification: NSNotification?) {
        print("Reload the graph in graph view Controller")
    }
    
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
