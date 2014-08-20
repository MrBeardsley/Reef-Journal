//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class GraphView: UIView {

    let black = UIColor.blackColor().CGColor
    let red = UIColor.redColor().CGColor
    let offset: CGFloat = 10.0



    ///////////////////////////////////////////////////////
    // This is just for development purposes. Remove later
    var dummyData: [CGFloat] = []
    let lowerBound = 350
    let upperBound = 550
    ///////////////////////////////////////////////////////

    required init(coder aDecoder: NSCoder) {
        ///////////////////////////////////////////////////////
        // This is just for development purposes. Remove later
        var index: Int
        for  index = 0; index < 10; ++index {
            var rndValue = CGFloat(lowerBound + Int(arc4random()) % (upperBound - lowerBound))
            dummyData.append(rndValue)
        }
        ///////////////////////////////////////////////////////
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()

        // Draw a boarder around the graph
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, black)
        let rectangle = self.bounds
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)

        // Draw the Axis
        let startPoint = CGPoint(x: self.bounds.origin.x + offset, y: self.bounds.origin.y + offset)
        let endPoint = CGPoint(x: startPoint.x + self.bounds.width - 2 * offset, y: startPoint.y + self.bounds.height - 2 * offset)
        CGContextSaveGState(context)
        CGContextSetLineCap(context, kCGLineCapSquare)
        CGContextSetStrokeColorWithColor(context, black)
        CGContextSetLineWidth(context, 3.0)
        CGContextMoveToPoint(context, startPoint.x, startPoint.y)
        CGContextAddLineToPoint(context, startPoint.x, endPoint.y)
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)


        // Place Labels

        // Draw the graph

        let xMultiplier: Int = 20
        let yMultiplier: CGFloat = 0.25
        CGContextSaveGState(context)
        CGContextSetStrokeColorWithColor(context, red)
        CGContextSetLineWidth(context, 2.0)
        for (index, element) in enumerate(dummyData) {

            if index == 0 {
                CGContextMoveToPoint(context, CGFloat(index) + offset + 2.0, element * yMultiplier)
            }
            else {
                CGContextAddLineToPoint(context, CGFloat(index * xMultiplier), element * yMultiplier)
            }
        }

        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
}
