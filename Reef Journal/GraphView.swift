//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit

private struct Dimensions {
    static let labelWidth: CGFloat = 21.0
    static let labelHeight: CGFloat = 14.0
    static let labelBottomMargin: CGFloat = 10.0
    static let margin: CGFloat = 20.0
}

@IBDesignable class GraphView: UIView {
    
    @IBOutlet weak var graphTitle: UILabel!

    var weekMeasurements = [Double?]()
    var monthMeasurements = [Double?]()
    var yearMeasurements = [Double?]()
    var scale: TimeScale = .Week
    var maxValue: CGFloat = 0
    var parameterType: Parameter?
    let calendar = NSCalendar.currentCalendar()
    
    
    private var dataPoints:[Double?] {
        get {
            switch self.scale {
            case .Week:
                return weekMeasurements
            case .Month:
                return monthMeasurements
            case .Year:
                return yearMeasurements
            }
        }
    }
    
    private var label1: UILabel = UILabel()
    private var label2: UILabel = UILabel()
    private var label3: UILabel = UILabel()
    private var label4: UILabel = UILabel()
    private var label5: UILabel = UILabel()
    private var label6: UILabel = UILabel()
    private var label7: UILabel = UILabel()
    
    // Colors
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        label1.textAlignment = .Center
        label2.textAlignment = .Center
        label3.textAlignment = .Center
        label4.textAlignment = .Center
        label5.textAlignment = .Center
        label6.textAlignment = .Center
        label7.textAlignment = .Center
        
        let color = UIColor.whiteColor()
        
        label1.textColor = color
        label2.textColor = color
        label3.textColor = color
        label4.textColor = color
        label5.textColor = color
        label6.textColor = color
        label7.textColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        drawBackgroundWithContext(ctx, inRect: rect)
        drawLine(ctx)
        drawDots(ctx)
        drawGrid(ctx)
        drawLabels(ctx)
    }
    
    private func drawBackgroundWithContext(context: CGContext, inRect rect: CGRect) {
        CGContextSaveGState(context)
        
        //set up background clipping area
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        let colors = [startColor.CGColor, endColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions())
        
        CGContextRestoreGState(context)
    }
    
    private func drawLine(context: CGContext) {
        let flattened: [Double] = self.dataPoints.flatMap { $0 }
        guard flattened.count > 1 else { return }
        guard let maxValue = flattened.maxElement() else { return }
        
        let width = self.frame.width
        let height = self.frame.height
        
        let graphPoints = self.dataPoints

        //calculate the x point
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - Dimensions.margin * 2 - 4) /
                CGFloat((graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += Dimensions.margin + 2
            return x
        }

        // calculate the y point
        
        let topBorder:CGFloat = 40
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let columnYPoint = { (graphPoint: Double) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
  
        // Set the color of the lines to white
        UIColor.whiteColor().setFill()
        UIColor.whiteColor().setStroke()
        
        let graphPath = UIBezierPath()
        
        // Find the first non-nil value and start drawing from there. We know there is at least one
        for i in 0..<graphPoints.count {
            if let measurementValue = graphPoints[i] {
                graphPath.moveToPoint(CGPoint(x:columnXPoint(i), y:columnYPoint(measurementValue)))
                break
            }
        }
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            if let measurementValue = graphPoints[i] {
                let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(measurementValue))
                graphPath.addLineToPoint(nextPoint)
            }
        }
        
        graphPath.stroke()
        
        CGContextSaveGState(context)
        
        let clippingPath = graphPath.copy() as! UIBezierPath
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        
        //6 - draw the gradient
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        
        //3 - add lines to the copied path to complete the clip area
        
        if let
            firstVal = flattened.first,
            lastVal = flattened.last,
            firstIndex = graphPoints.indexOf({ $0 == firstVal }),
            lastIndex = graphPoints.reverse().indexOf({ $0 == lastVal }) {
                
                clippingPath.addLineToPoint(CGPoint(x: columnXPoint(lastIndex.base - 1), y: height - 50))
                clippingPath.addLineToPoint(CGPoint(x: columnXPoint(firstIndex), y: height - 50))
                clippingPath.closePath()
                
                //4 - add the clipping path to the context
                clippingPath.addClip()
                
                let highestYPoint = columnYPoint(maxValue)
                startPoint = CGPoint(x:Dimensions.margin, y: highestYPoint)
                endPoint = CGPoint(x:Dimensions.margin, y:self.bounds.height)
                
                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions())
        }

        CGContextRestoreGState(context)
    }
    
    private func drawDots(context: CGContext) {
        let flattened: [Double] = self.dataPoints.flatMap { $0 }
        guard !flattened.isEmpty else { return }
        guard let maxValue = flattened.maxElement() else { return }
        
        let width = self.frame.width
        let height = self.frame.height
        
        let graphPoints = self.dataPoints
        
        //calculate the x point
        
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - Dimensions.margin * 2 - 4) /
                CGFloat((graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += Dimensions.margin + 2
            return x
        }
        
        // calculate the y point
        
        let topBorder:CGFloat = 40
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let columnYPoint = { (graphPoint: Double) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        // Draw the circles on top of graph stroke
        for i in 0 ..< dataPoints.count {
            if let measurementValue = dataPoints[i] {
                var point = CGPoint(x:columnXPoint(i), y:columnYPoint(measurementValue))
                point.x -= 5.0/2
                point.y -= 5.0/2
                
                CGContextSaveGState(context)
                UIColor.whiteColor().setFill()
                UIColor.whiteColor().setStroke()
                
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0, height: 5.0)))
                circle.fill()
                
                CGContextRestoreGState(context)
                
                CGContextSaveGState(context)
                endColor.setFill()
                endColor.setStroke()
                
                point.x += 2.5 / 2
                point.y += 2.5 / 2
                
                let innerCircle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 2.5, height: 2.5)))
                innerCircle.fill()
                
                CGContextRestoreGState(context)
            }
        }
        
        
    }
    
    private func drawGrid(context: CGContext) {
        //Draw horizontal graph lines on the top of everything
        let width = self.frame.width
        let height = self.frame.height
        let topBorder:CGFloat = 40
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        
        let linePath = UIBezierPath()
        
        //top line
        linePath.moveToPoint(CGPoint(x:Dimensions.margin, y: topBorder))
        linePath.addLineToPoint(CGPoint(x: width - Dimensions.margin,
            y:topBorder))
        
        //center line
        linePath.moveToPoint(CGPoint(x: Dimensions.margin, y: graphHeight/2 + topBorder))
        linePath.addLineToPoint(CGPoint(x:width - Dimensions.margin, y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.moveToPoint(CGPoint(x: Dimensions.margin, y:height - bottomBorder))
        linePath.addLineToPoint(CGPoint(x: width - Dimensions.margin, y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    
    private func drawLabels(context: CGContext) {
        let originY: CGFloat = self.frame.height - Dimensions.labelHeight - Dimensions.labelBottomMargin
        let width = self.frame.width - Dimensions.margin * 2 - Dimensions.labelWidth * 2
        let emptySpace = width - Dimensions.labelWidth * 5
        let spacing = emptySpace / 6
        
        let today = NSDate()
        
        
        let getDay = { (date: NSDate, number: Int) -> Int in
            let calendar = NSCalendar.currentCalendar()
            if let newDate = calendar.dateByAddingUnit(.Day, value: number, toDate: date, options: .MatchStrictly) {
                let components = calendar.components([.Day], fromDate: newDate)
                return components.day
            }
            return 0
        }
        
        switch scale {
        case .Week:
            
            let components = calendar.components([.Day], fromDate: today)
            
            label1.text = "\(getDay(today, -6))"
            label2.text = "\(getDay(today, -5))"
            label3.text = "\(getDay(today, -4))"
            label4.text = "\(getDay(today, -3))"
            label5.text = "\(getDay(today, -2))"
            label6.text = "\(getDay(today, -1))"
            label7.text = "\(components.day)"
            
            label1.frame = CGRect(x: Dimensions.margin, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            label2.frame = CGRect(x: label1.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            label3.frame = CGRect(x: label2.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            label4.frame = CGRect(x: label3.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            label5.frame = CGRect(x: label4.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            label6.frame = CGRect(x: label5.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            label7.frame = CGRect(x: self.frame.width - Dimensions.margin - Dimensions.labelWidth, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
            
            self.addSubview(label1)
            self.addSubview(label2)
            self.addSubview(label3)
            self.addSubview(label4)
            self.addSubview(label5)
            self.addSubview(label6)
            self.addSubview(label7)
            break
        case .Month:
            
            break
        case .Year:
            
            break
        }
    }

    private func differenceBetweenRecentDate(recentDate: NSDate, olderDate: NSDate) -> Int {
        let difference = calendar.components([.Year, .Month, .Day], fromDate: olderDate, toDate: recentDate, options: [.WrapComponents])
        return difference.day
    }
}
