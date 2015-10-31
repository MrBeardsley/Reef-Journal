//
//  GraphView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit

@IBDesignable class GraphView: UIView {

    var dataPoints = [(NSDate, Double)]()
    var maxValue: CGFloat = 0
    var parameterType: Parameter?
    let calendar = NSCalendar.currentCalendar()
    
    // Colors
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        drawBackgroundWithContext(ctx, inRect: rect)
        drawGrid(ctx)
        drawLine(ctx)
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
        guard !dataPoints.isEmpty else { return }
        
    }
    
    private func drawGrid(context: CGContext) {
        
    }
    
    private func drawLabels(context: CGContext) {
        
    }

    private func differenceBetweenRecentDate(recentDate: NSDate, olderDate: NSDate) -> Int {
        let difference = calendar.components([.Year, .Month, .Day], fromDate: olderDate, toDate: recentDate, options: [.WrapComponents])
        return difference.day
    }
}
