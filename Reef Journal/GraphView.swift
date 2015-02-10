//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

class GraphView: UIScrollView {

    var dataPoints: Array<(date: NSDate, value: Double)> = []
    var maxValue: CGFloat = 0
    var parameterType: Parameter?
    let calendar = NSCalendar.currentCalendar()
    
    // Colors
    let black = UIColor.blackColor()
    let green = UIColor(red: 106.0/255.0, green: 168.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    let lightGreen = UIColor(red: 120.0/255.0, green: 253.0/255.0, blue: 120.0/255.0, alpha:1.0)
    let blue = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 235.0/255.0, alpha: 1.0)
    let lightBlue = UIColor(red: 94.0/255.0, green: 156.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let red = UIColor(red: 205.0/255.0, green: 1.0/255.0, blue: 1.0/255.0, alpha: 1.0)
    let lightRed = UIColor(red: 250.0/255.0, green: 119.0/255.0, blue: 119.0/255.0, alpha: 1.0)

    // Drawing support
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
        drawTicks(rect, context: currentContext)
        drawLabels(rect, context: currentContext)
        drawGraph(rect, context: currentContext)
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

    private func drawTicks(rect: CGRect, context: CGContext) {
        let drawingOffset = axisOffset + axisWidth
        let tickOriginX = rect.origin.x + 22.0
        let tickOriginY = rect.origin.y + 20.0
        let midPointY = ((rect.size.height - 50.0 - drawingOffset) / 2.0) + drawingOffset
        let midPointX = ((rect.size.width - drawingOffset) / 2.0) + drawingOffset

        var path = UIBezierPath()

        CGContextSaveGState(context)
        path.moveToPoint(CGPoint(x: tickOriginX, y: rect.size.height - 50.0))
        path.addLineToPoint(CGPoint(x: rect.origin.x + axisOffset, y: rect.size.height - 50.0))

        black.set()
        path.stroke()
        CGContextRestoreGState(context)

        CGContextSaveGState(context)
        path.moveToPoint(CGPoint(x: tickOriginX, y: midPointY))
        path.addLineToPoint(CGPoint(x: rect.origin.x + axisOffset, y: midPointY))

        black.set()
        path.stroke()
        CGContextRestoreGState(context)

        CGContextSaveGState(context)
        path.moveToPoint(CGPoint(x: midPointX, y: tickOriginY))
        path.addLineToPoint(CGPoint(x: midPointX, y: rect.origin.y + drawingOffset - 1.0))

        black.set()
        path.stroke()
        CGContextRestoreGState(context)

        CGContextSaveGState(context)
        path.moveToPoint(CGPoint(x: rect.origin.x + rect.size.width - 1.0, y: tickOriginY))
        path.addLineToPoint(CGPoint(x: rect.origin.x + rect.size.width - 1.0, y: rect.origin.y + drawingOffset - 1.0))

        black.set()
        path.stroke()
        CGContextRestoreGState(context)

    }

    private func drawLabels(rect: CGRect, context: CGContext) {
        let decimalPlaces = decimalPlacesForParameter(parameterType!)
        let format = "%." + String(decimalPlaces) + "f"
        let midValue = maxValue / 2.0
        let drawingOffset = axisOffset + axisWidth
        let midPosition = (rect.size.height - drawingOffset) / 2.0 + 17.0

        let maxString = NSMutableAttributedString(string: String(format: format, Double(maxValue)))
        let midString = NSMutableAttributedString(string: String(format: format, Double(midValue)))

        CGContextSaveGState(context)
        // reverse the y-axis
        CGContextScaleCTM(context, 1, -1);
        // move the origin to put the drawing back in the visible area
        CGContextTranslateCTM(context, 0, -rect.size.height)
        maxString.drawAtPoint(CGPoint(x: rect.origin.x, y: 42.5))
        midString.drawAtPoint(CGPoint(x: rect.origin.x, y: midPosition))
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

        var lineColor: UIColor
        var fillColor: UIColor

        switch parameterType! {
        case .Temperature:
            lineColor = red
            fillColor = lightRed
        case .Ammonia, .Nitrite, .Nitrate, .Phosphate:
            lineColor = green
            fillColor = lightGreen
        case .Salinity, .pH, .Alkalinity, .Calcium, .Magnesium, .Strontium, .Potasium:
            lineColor = blue
            fillColor = lightBlue
        }

        lineColor.set()
        path.stroke()

        fillColor.set()
        path.fill()

        CGContextRestoreGState(context)
    }

    private func differenceBetweenRecentDate(recentDate: NSDate, olderDate: NSDate) -> Int {
        let flags = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let difference = calendar.components(flags, fromDate: olderDate, toDate: recentDate, options: nil)

        return difference.day
    }
}
