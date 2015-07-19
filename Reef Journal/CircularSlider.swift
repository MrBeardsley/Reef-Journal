//
//  CircularSlider.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/13/15.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

enum DrawingParameters: CGFloat {
    case Padding = 30.0
    case LineWidth = 40.0
    case FontSize = 48.0
}


// MARK: Math Helpers 

func DegreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

func RadiansToDegrees (value:Double) -> Double {
    return value * 180.0 / M_PI
}

func Square (value:CGFloat) -> CGFloat {
    return value * value
}


// MARK: Circular Slider

class CircularSlider: UIControl {

    var textField: UITextField?
    var radius: CGFloat = 0
    var angle: Int = 90
    var startColor = UIColor.blueColor()
    var endColor = UIColor.purpleColor()
    
    // Custom initializer
    convenience init(startColor: UIColor, endColor: UIColor, frame: CGRect){
        self.init(frame: frame)
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    // Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
        
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - DrawingParameters.Padding.rawValue
        
        //Define the Font
        let font = UIFont.systemFontOfSize(DrawingParameters.FontSize.rawValue)
        //Calculate font size needed to display 3 numbers
        let str = "00.0" as NSString
        let fontSize: CGSize = str.sizeWithAttributes([NSFontAttributeName:font])
        
        //Using a TextField area we can easily modify the control to get user input from this field
        let textFieldRect = CGRectMake(
            (frame.size.width  - fontSize.width) / 2.0,
            (frame.size.height - fontSize.height) / 2.0,
            fontSize.width, fontSize.height);
        
        textField = UITextField(frame: textFieldRect)
        textField?.backgroundColor = UIColor.clearColor()
        textField?.textColor = UIColor(white: 0.5, alpha: 1.0)
        textField?.textAlignment = .Center
        textField?.font = font
        textField?.text = "\(self.angle)"
        
        addSubview(textField!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        return true
    }
    
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        let lastPoint = touch.locationInView(self)
        
        self.moveHandle(lastPoint)
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)

        print("touch up")
    }
    
    
    
    
    //Use the draw rect to draw the Background, the Circle and the Handle
    override func drawRect(rect: CGRect){
        super.drawRect(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        
        /** Draw the Background **/
        
        CGContextAddArc(ctx, CGFloat(self.frame.size.width / 2.0), CGFloat(self.frame.size.height / 2.0), radius, 0, CGFloat(M_PI * 2), 0)
        UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0).set()
        
        CGContextSetLineWidth(ctx, 48)
        CGContextSetLineCap(ctx, CGLineCap.Butt)
        
        CGContextDrawPath(ctx, CGPathDrawingMode.Stroke)
        
        
        /** Draw the circle **/
        
        /** Create THE MASK Image **/
        UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width,self.bounds.size.height));
        let imageCtx = UIGraphicsGetCurrentContext()
        CGContextAddArc(imageCtx, CGFloat(self.frame.size.width/2)  , CGFloat(self.frame.size.height/2), radius, 0, CGFloat(DegreesToRadians(Double(angle))) , 0);
        UIColor.redColor().set()
        
        //Use shadow to create the Blur effect
        //CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), CGFloat(self.angle/15), UIColor.blackColor().CGColor);
        CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), CGFloat(15), UIColor.blackColor().CGColor);
       
        //define the path
        CGContextSetLineWidth(imageCtx, DrawingParameters.LineWidth.rawValue)
        CGContextDrawPath(imageCtx, CGPathDrawingMode.Stroke)
        
        //save the context content into the image mask
        let mask:CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())!;
        UIGraphicsEndImageContext();
        
        /** Clip Context to the mask **/
        CGContextSaveGState(ctx)
        
        CGContextClipToMask(ctx, self.bounds, mask)
        
        
        /** The Gradient **/
        
        // Split colors in components (rgba)
        let startColorComps:UnsafePointer<CGFloat> = CGColorGetComponents(startColor.CGColor);
        let endColorComps:UnsafePointer<CGFloat> = CGColorGetComponents(endColor.CGColor);

        let components : [CGFloat] = [
            startColorComps[0], startColorComps[1], startColorComps[2], 1.0,     // Start color
            endColorComps[0], endColorComps[1], endColorComps[2], 1.0      // End color
        ]
        
        // Setup the gradient
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(baseSpace, components, nil, 2)

        // Gradient direction
        let startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))
        let endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))
        
        // Draw the gradient
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, CGGradientDrawingOptions())
        CGContextRestoreGState(ctx)

        /* Draw the handle */
        drawTheHandle(ctx)

    }
    
    
    
    /** Draw a white knob over the circle **/
    
    func drawTheHandle(ctx:CGContextRef){
        
        CGContextSaveGState(ctx);
        
        //I Love shadows
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, UIColor.blackColor().CGColor);
        
        //Get the handle position
        let handleCenter = pointFromAngle(angle)

        //Draw It!
        UIColor(white:1.0, alpha:0.7).set();
        CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, DrawingParameters.LineWidth.rawValue, DrawingParameters.LineWidth.rawValue));
        
        CGContextRestoreGState(ctx);
    }
    
    
    
    /** Move the Handle **/

    func moveHandle(lastPoint:CGPoint){
        
        //Get the center
        let centerPoint: CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        //Calculate the direction from a center point and a arbitrary position.
        let currentAngle: Double = AngleFromNorth(centerPoint, p2: lastPoint, flipped: false);
        let angleInt = Int(floor(currentAngle))
        let roundedAngle = ((360 - currentAngle) / 24.0)
        let measurementValue: Double = round(roundedAngle * 10) / 10

        //Store the new angle
        angle = Int(360 - angleInt)

        //Update the textfield
        textField!.text = "\(measurementValue)"
        print(roundedAngle)
        
        //Redraw
        setNeedsDisplay()
    }
    
    /** Given the angle, get the point position on circumference **/
    func pointFromAngle(angleInt:Int)->CGPoint{
    
        //Circle center
        let centerPoint = CGPointMake(self.frame.size.width / 2.0 - DrawingParameters.LineWidth.rawValue / 2.0, self.frame.size.height / 2.0 - DrawingParameters.LineWidth.rawValue / 2.0);

        //The point position on the circumference
        var result: CGPoint = CGPointZero
        let y = round(Double(radius) * sin(DegreesToRadians(Double(-angleInt)))) + Double(centerPoint.y)
        let x = round(Double(radius) * cos(DegreesToRadians(Double(-angleInt)))) + Double(centerPoint.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
            
        return result;
    }
    
    
    //Sourcecode from Apple example clockControl
    //Calculate the direction in degrees from a center point to an arbitrary position.
    func AngleFromNorth(p1: CGPoint , p2: CGPoint , flipped: Bool) -> Double {
        var v: CGPoint  = CGPointMake(p2.x - p1.x, p2.y - p1.y)
        let vmag: CGFloat = Square(Square(v.x) + Square(v.y))
        var result: Double = 0.0
        v.x /= vmag
        v.y /= vmag
        let radians = Double(atan2(v.y,v.x))
        result = RadiansToDegrees(radians)
        return (result >= 0  ? result : result + 360.0);
    }

}
