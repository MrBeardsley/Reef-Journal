//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


@IBDesignable class GraphView: UIView {
    
    // MARK: - Interface Outlets
    @IBOutlet weak var graphTitle: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var midValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!    
    
    // MARK: - Properties
    var weekMeasurements = [Double?]()
    var monthMeasurements = [Double?]()
    var yearMeasurements = [Double?]()
    var scale: TimeScale = .Week
    var maxValue: CGFloat = 0
    var currentParameter: Parameter?
    private let calendar = NSCalendar.currentCalendar()
    private let formatter = NSNumberFormatter()
    
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
    private let axisLabels: [UILabel]
    
    // Colors
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()

    // MARK: - Init/Deinit
    required init?(coder aDecoder: NSCoder) {
        self.axisLabels = [label1, label2, label3, label4, label5, label6, label7]
        super.init(coder: aDecoder)
        
        let labelColor = UIColor.whiteColor()
        
        for label in self.axisLabels {
            label.textAlignment = .Center
            label.textColor = labelColor
            self.addSubview(label)
        }
    }
    
    override init(frame: CGRect) {
        self.axisLabels = [label1, label2, label3, label4, label5, label6, label7]
        super.init(frame: frame)
        
        let labelColor = UIColor.whiteColor()
        
        for label in self.axisLabels {
            label.textAlignment = .Center
            label.textColor = labelColor
            self.addSubview(label)
        }
    }

    // MARK: - Drawing
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        drawBackgroundWithContext(ctx, inRect: rect)
        drawLine(ctx)
        drawDots(ctx)
        drawGrid(ctx)
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
        
        let width = self.frame.width - Dimensions.labelWidth
        let height = self.frame.height
        
        let graphPoints = self.dataPoints
        let minGraphValue = self.bottomOfGraphRange()

        //calculate the x point
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - Dimensions.margin * 2 - 4) / CGFloat((graphPoints.count - 1))
            var x: CGFloat = CGFloat(column) * spacer
            x += Dimensions.margin + 2 + Dimensions.labelWidth / 2
            return x
        }

        // calculate the y point
        
        let topBorder:CGFloat = 40
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        
        let columnYPoint = { (graphPoint: Double) -> CGFloat in
            var y = CGFloat(graphPoint - minGraphValue) / CGFloat(maxValue - minGraphValue) * graphHeight
            
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
        
        let width = self.frame.width - Dimensions.labelWidth
        let height = self.frame.height
        
        let graphPoints = self.dataPoints
        let minGraphValue = self.bottomOfGraphRange()
        
        //calculate the x point
        
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - Dimensions.margin * 2 - 4) / CGFloat((graphPoints.count - 1))
            var x = CGFloat(column) * spacer
            x += Dimensions.margin + 2 + Dimensions.labelWidth / 2
            return x
        }
        
        // calculate the y point
        
        let topBorder:CGFloat = 40
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let columnYPoint = { (graphPoint: Double) -> CGFloat in
            var y = CGFloat(graphPoint - minGraphValue) / CGFloat(maxValue - minGraphValue) * graphHeight
            
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
    
    func drawLabels() {
        guard let param = self.currentParameter else { return }
        
        let originY: CGFloat = self.frame.height - Dimensions.labelHeight - Dimensions.labelBottomMargin
        let originX: CGFloat = self.frame.origin.x + self.frame.size.width / 2.0 - Dimensions.labelWidth / 2.0
        let startingRect = CGRect(x: originX, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
        
        // Remove all of the labels in case some are not needed later
        for label in self.axisLabels {
            label.hidden = true
            if label.frame.origin.x == 0 {
                label.frame = startingRect
            }
        }
        
        unitsLabel.text = unitLabelForParameterType(param)

        
        let today = NSDate()
        
        let getDay = { (date: NSDate, number: Int) -> Int in
            let calendar = NSCalendar.currentCalendar()
            if let newDate = calendar.dateByAddingUnit(.Day, value: number, toDate: date, options: .MatchStrictly) {
                let components = calendar.components([.Day], fromDate: newDate)
                return components.day
            }
            return 0
        }
        
        formatter.maximumFractionDigits = decimalPlacesForParameter(param)
        
        let flattened: [Double] = self.dataPoints.flatMap { $0 }
        
        self.maxValueLabel.text = ""
        self.midValueLabel.text = ""
        self.minValueLabel.text = ""
        
        if let maxValue = flattened.maxElement() {
            let bottomOfGraph = bottomOfGraphRange()
            let graphRange = maxValue - bottomOfGraph
            let midValue = graphRange / 2.0 + bottomOfGraph
            
            if let
                maxString = formatter.stringFromNumber(maxValue),
                midString = formatter.stringFromNumber(midValue),
                minString = formatter.stringFromNumber(bottomOfGraph) {
                    
                self.maxValueLabel.text = "\(maxString)"
                self.midValueLabel.text = "\(midString)"
                self.minValueLabel.text = "\(minString)"
            }
        }
        
        switch scale {
        case .Week:
            
            let components = calendar.components([.Day], fromDate: today)
            let width = self.frame.width - Dimensions.margin * 2 - Dimensions.labelWidth * 2
            let emptySpace = width - Dimensions.labelWidth * 5
            let spacing = emptySpace / 6
            
            UIView.animateWithDuration(0.5, animations: { [unowned self] in
                
                self.graphTitle.text = self.calendar.monthSymbols[self.calendar.component(.Month, fromDate: today) - 1]
            
                self.label1.text = "\(getDay(today, -6))"
                self.label2.text = "\(getDay(today, -5))"
                self.label3.text = "\(getDay(today, -4))"
                self.label4.text = "\(getDay(today, -3))"
                self.label5.text = "\(getDay(today, -2))"
                self.label6.text = "\(getDay(today, -1))"
                self.label7.text = "\(components.day)"
                
                self.label1.frame = CGRect(x: Dimensions.margin, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label2.frame = CGRect(x: self.label1.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label3.frame = CGRect(x: self.label2.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label4.frame = CGRect(x: self.label3.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label5.frame = CGRect(x: self.label4.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label6.frame = CGRect(x: self.label5.frame.origin.x + Dimensions.labelWidth + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label7.frame = CGRect(x: self.frame.width - Dimensions.margin - Dimensions.labelWidth, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                
                for label in self.axisLabels {
                    label.hidden = false
                }
            })
            
            break
            
        case .Month:
            
            let components = calendar.components([.Day], fromDate: today)
            let width = self.frame.width - Dimensions.margin * 2 - Dimensions.labelWidth * 2
            let emptySpace = width - Dimensions.labelWidth * 3
            let spacing = emptySpace / 4 + Dimensions.labelWidth
            
            UIView.animateWithDuration(0.5, animations: { [unowned self] in
                
                self.graphTitle.text = self.calendar.monthSymbols[self.calendar.component(.Month, fromDate: today) - 1]
            
                self.label2.text = "\(getDay(today, -28))"
                self.label3.text = "\(getDay(today, -21))"
                self.label4.text = "\(getDay(today, -14))"
                self.label5.text = "\(getDay(today, -7))"
                self.label6.text = "\(components.day)"
                
                self.label1.frame = CGRect(x: Dimensions.margin, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label2.frame = CGRect(x: Dimensions.margin, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label3.frame = CGRect(x: self.label2.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label4.frame = CGRect(x: self.label3.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label5.frame = CGRect(x: self.label4.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label6.frame = CGRect(x: self.label5.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label7.frame = CGRect(x: self.label5.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                
                self.label1.hidden = true
                self.label2.hidden = false
                self.label3.hidden = false
                self.label4.hidden = false
                self.label5.hidden = false
                self.label6.hidden = false
                self.label7.hidden = true
            })
            
            break
            
        case .Year:
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Month], fromDate: today)
            let width = self.frame.width - Dimensions.margin * 2 - Dimensions.labelWidth * 2
            let emptySpace = width - Dimensions.labelWidth * 2
            let spacing = emptySpace / 3 + Dimensions.labelWidth
            
            let getMonth = { (date: NSDate, number: Int) -> Int in
                let calendar = NSCalendar.currentCalendar()
                if let newDate = calendar.dateByAddingUnit(.Month, value: number, toDate: date, options: .MatchStrictly) {
                    let components = calendar.components([.Month], fromDate: newDate)
                    return components.month
                }
                return 0
            }
            
            UIView.animateWithDuration(0.5, animations: { [unowned self] in
                
                self.graphTitle.text = "\(calendar.component(.Year, fromDate: today))"
                
                self.label2.text = "\(calendar.shortMonthSymbols[getMonth(today, -9) - 1])"
                self.label3.text = "\(calendar.shortMonthSymbols[getMonth(today, -6) - 1])"
                self.label4.text = "\(calendar.shortMonthSymbols[getMonth(today, -3) - 1])"
                self.label5.text = "\(calendar.shortMonthSymbols[components.month - 1])"
                
                self.label1.frame = CGRect(x: Dimensions.margin, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label2.frame = CGRect(x: Dimensions.margin, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label3.frame = CGRect(x: self.label2.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label4.frame = CGRect(x: self.label3.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label5.frame = CGRect(x: self.label4.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label6.frame = CGRect(x: self.label4.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                self.label7.frame = CGRect(x: self.label4.frame.origin.x + spacing, y: originY, width: Dimensions.labelWidth, height: Dimensions.labelHeight)
                
                self.label1.hidden = true
                self.label2.hidden = false
                self.label3.hidden = false
                self.label4.hidden = false
                self.label5.hidden = false
                self.label6.hidden = true
                self.label7.hidden = true
            })
            
            break
        }
    }
    
    // MARK: - Private helper functions
    
    private func bottomOfGraphRange() -> Double {
        let flattened: [Double] = dataPoints.flatMap { $0 }
        
        guard !flattened.isEmpty else { return 0 }
        guard let minValue = flattened.minElement() else { return 0 }
        
        let floored = floor(minValue)
        
        if floored < 2 {
            return floored
        }
        else {
            return floor(floored - (floored / 5.0))
        }
    }
}

// MARK: - Constants
private struct Dimensions {
    static let labelWidth: CGFloat = 32.0
    static let labelHeight: CGFloat = 20.0
    static let labelBottomMargin: CGFloat = 15.0
    static let margin: CGFloat = 20.0
}
