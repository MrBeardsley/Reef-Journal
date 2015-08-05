//
//  GraphAxes.swift
//  
//
//  Created by Christopher Harding on 6/16/15
//
//

import UIKit

class GraphAxesView: UIView {

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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Flip the coordinate system so the origin ins in the bottom left
        self.transform = CGAffineTransformMakeScale(1, -1)
    }

    override func drawRect(rect: CGRect) {

        let currentContext = UIGraphicsGetCurrentContext()
        drawAxes(rect, context: currentContext)
        drawTicks(rect, context: currentContext)
        drawLabels(rect, context: currentContext)
    }

    private func drawAxes(rect: CGRect, context: CGContext) {
        let path = UIBezierPath()

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

        let path = UIBezierPath()

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
    
}
