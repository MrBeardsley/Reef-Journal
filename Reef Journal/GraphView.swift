//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var dataPoints: [(NSDate, Double)] = []

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {

        // Placeholder drawing just to get something on the screen
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        let rectangle = self.bounds
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)

        // Draw the Axis

        // Place Labels

        // Draw the graph

    }
}
