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
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true)]
    
            var error: NSError?
            if let results = context?.executeFetchRequest(fetchRequest, error: &error) {
                if let aMeasurement = results.last as? Measurement {
                    println(aMeasurement)
                }
            }
        }
    }
}
