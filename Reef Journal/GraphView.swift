//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class GraphView: UIView {

    let black = UIColor.blackColor()
    let green = UIColor(red: 106.0/255.0, green:168.0/255.0, blue:79.0/255.0, alpha:1.0)
    let axisOffset: CGFloat = 25.0
    let axisWidth: CGFloat = 3.0

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

        // Flip the coordinate system so the origin ins in the bottom left
        self.transform = CGAffineTransformMakeScale(1, -1)
    }

    override func drawRect(rect: CGRect) {

        let currentContext = UIGraphicsGetCurrentContext()

        drawAxes(rect, context: currentContext)
        drawGraph(rect, context: currentContext)

        // Place Labels

        // Draw a boarder around the graph
        CGContextSaveGState(currentContext)
        CGContextSetLineWidth(currentContext, 1.0)
        CGContextSetStrokeColorWithColor(currentContext, black.CGColor)
        let rectangle = self.bounds
        CGContextAddRect(currentContext, rectangle)
        CGContextStrokePath(currentContext)
        CGContextRestoreGState(currentContext)
    }

    private func drawAxes(rect: CGRect, context: CGContext) {
        var path = UIBezierPath()

        CGContextSaveGState(context)
        // Start at the top left, drop to the origin, and then go right
        path.moveToPoint(CGPoint(x: rect.origin.x + axisOffset, y: rect.size.height))
        path.addLineToPoint(CGPoint(x: rect.origin.x + axisOffset, y: rect.origin.y + axisOffset))
        path.addLineToPoint(CGPoint(x: rect.size.width, y: rect.origin.y + axisOffset))
        path.lineWidth = axisWidth

        black.set()
        path.stroke()

        CGContextRestoreGState(context)
    }

    private func drawGraph(rect: CGRect, context: CGContext) {
        var path = UIBezierPath()
        let xMultiplier: CGFloat = 20
        let yMultiplier: CGFloat = 0.5
        let drawingOffset = axisOffset + axisWidth


        CGContextSaveGState(context)

        path.moveToPoint(CGPoint(x: rect.origin.x + drawingOffset, y: rect.origin.y + drawingOffset))

        // Draw the lines.
        for (index, element) in enumerate(dummyData) {
            path.addLineToPoint(CGPoint(x: CGFloat(index) * xMultiplier + drawingOffset, y: element * yMultiplier + drawingOffset))
        }

        path.addLineToPoint(CGPoint(x: CGFloat(dummyData.count - 1) * xMultiplier + drawingOffset , y: rect.origin.y + drawingOffset))
        path.closePath()

        green.set()
        path.stroke()
        path.fill()

        CGContextRestoreGState(context)
    }
}
