//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var dataPoints: Array<(date: NSDate, value: Double)> = []
    var maxValue: CGFloat = 0
    let calendar = NSCalendar.currentCalendar()
    
    // Drawing support
    let black = UIColor.blackColor()
    let green = UIColor(red: 106.0/255.0, green:168.0/255.0, blue:79.0/255.0, alpha:1.0)
    let lightGreen = UIColor(red: 106.0/255.0, green:168.0/255.0, blue:79.0/255.0, alpha:0.5)
    let axisOffset: CGFloat = 25.0
    let axisWidth: CGFloat = 2.0

    required init(coder aDecoder: NSCoder) {
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

        // If there is no data, don't bother drawing anything.
        if dataPoints.isEmpty {
            return
        }

        let path = UIBezierPath()
        let drawingOffset = axisOffset + axisWidth
        let graphWidth = rect.size.width - drawingOffset
        let yMultiplier: CGFloat = (rect.size.height - drawingOffset - 50.0) / maxValue


        CGContextSaveGState(context)

        // Special case for a single datapoint
        if dataPoints.count == 1 {
            path.moveToPoint(CGPoint(x: rect.size.width, y: CGFloat(dataPoints[0].1) * yMultiplier + drawingOffset))
            path.addLineToPoint(CGPoint(x: rect.size.width, y: rect.origin.y + drawingOffset))
            path.addLineToPoint(CGPoint(x: rect.origin.x + drawingOffset, y: rect.origin.y + drawingOffset))
            path.addLineToPoint(CGPoint(x: rect.origin.x + drawingOffset, y: CGFloat(dataPoints[0].1) * yMultiplier + drawingOffset))
            path.closePath()
        }
        else {
            let firstDate = dataPoints.first!.0
            let lastDate = dataPoints.last!.0
            let xMultiplier = graphWidth / CGFloat(differenceBetweenRecentDate(lastDate, olderDate: firstDate))

            // Draw the lines.
            var previousElementDate: NSDate? = nil
            var previousElementXCoord: CGFloat = 0

            path.moveToPoint(CGPoint(x: rect.origin.x + drawingOffset, y: rect.origin.y + drawingOffset))

            for (index, element) in enumerate(dataPoints) {

                if previousElementDate != nil {
                    var distanceFromLastPoint = CGFloat(differenceBetweenRecentDate(element.0, olderDate: previousElementDate!)) * xMultiplier
                    previousElementXCoord += distanceFromLastPoint
                    path.addLineToPoint(CGPoint(x: previousElementXCoord, y: CGFloat(element.1) * yMultiplier + drawingOffset))
                }
                else {
                    path.addLineToPoint(CGPoint(x: drawingOffset, y: CGFloat(element.1) * yMultiplier + drawingOffset))
                    previousElementXCoord = drawingOffset
                }

                previousElementDate = element.0
            }

            path.addLineToPoint(CGPoint(x: previousElementXCoord, y: rect.origin.y + drawingOffset))
            path.closePath()
        }

        green.set()
        path.stroke()

        lightGreen.set()
        path.fill()

        CGContextRestoreGState(context)
    }

    private func differenceBetweenRecentDate(recentDate: NSDate, olderDate: NSDate) -> Int {
        let flags = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let difference = calendar.components(flags, fromDate: olderDate, toDate: recentDate, options: nil)

        return difference.day
    }
}
