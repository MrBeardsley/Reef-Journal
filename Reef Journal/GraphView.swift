//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit

class GraphView: UIScrollView {

    var dataPoints = [(NSDate, Double)]()
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Flip the coordinate system so the origin ins in the bottom left
        self.transform = CGAffineTransformMakeScale(1, -1)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        // Temporary
        UIColor.blueColor().set()
        CGContextFillRect(ctx, rect)
        
        drawBackground(ctx)
        drawGrid(ctx)
        drawLine(ctx)
        drawLabels(ctx)
    }
    
    private func drawBackground(context: CGContext) {
        
    }
    
    private func drawLine(context: CGContext) {
        guard !dataPoints.isEmpty else { return }
        
    }
    
    private func drawGrid(context: CGContext) {
        
    }
    
    private func drawLabels(context: CGContext) {
        
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

            for (_, element) in dataPoints.enumerate() {

                if previousElementDate != nil {
                    let distanceFromLastPoint = CGFloat(differenceBetweenRecentDate(element.0, olderDate: previousElementDate!)) * xMultiplier
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
        let difference = calendar.components([.Year, .Month, .Day], fromDate: olderDate, toDate: recentDate, options: [.WrapComponents])
        return difference.day
    }
}
