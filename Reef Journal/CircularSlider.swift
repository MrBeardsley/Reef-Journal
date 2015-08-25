//
//  CircularSlider.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/13/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


private struct ColorPalette {
    static let lightBlue = UIColor.cyanColor()
    static let darkBlue = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
    static let textGrey = UIColor(white: 0.5, alpha: 1.0)
}

private enum DrawingParameters: CGFloat {
    case Padding = 30.0
    case LineWidth = 40.0
    case FontSize = 48.0
}

struct DecimalFormat {
    static let None = "%.0f"
    static let One = "%.1f"
    static let Two = "%.2f"
    static let Three = "%.3f"
}


// MARK: - Math Helpers

private func DegreesToRadians(value: Double) -> Double {
    return value * M_PI / 180.0
}

private func RadiansToDegrees(value: Double) -> Double {
    return value * 180.0 / M_PI
}

private func Square(value: CGFloat) -> CGFloat {
    return value * value
}

//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
private func AngleFromNorth(p1: CGPoint, p2: CGPoint, flipped: Bool) -> Double {
    var v: CGPoint  = CGPointMake(p2.x - p1.x, p2.y - p1.y)
    let vmag: CGFloat = Square(Square(v.x) + Square(v.y))
    var result: Double = 0.0
    v.x /= vmag
    v.y /= vmag
    let radians = Double(atan2(v.y, v.x))
    result = RadiansToDegrees(radians)
    return (result >= 0  ? result : result + 360.0);
}

// MARK: - CircularSlider Class

class CircularSlider: UIControl, UITextFieldDelegate {

    // Mark: - IBOutlets

    @IBOutlet var detailController: DetailViewController!

    // MARK: - Properties

    var startColor: UIColor = ColorPalette.lightBlue
    var endColor: UIColor = ColorPalette.darkBlue

    var maxValue: Double = 0
    var minValue: Double = 0
    var valueFormat: String = DecimalFormat.None
    var value: Double {
        get {
            return _value
        }

        set {
            moveHandle(valueToPoint(newValue))
        }
    }

    // MARK: - Private Properties
    
    private var _value: Double = 0 {
        didSet {
            self.textField?.text = String(format: self.valueFormat, _value)
        }
    }

    private var textField: UITextField?
    private var fontSize: CGSize = CGSize(width: 0, height: 0)
    private var radius: CGFloat = 0
    private var angle: Double = 0
    private var _setup: Bool = false

    // MARK: - Init/Deinit

    convenience init(startColor: UIColor, endColor: UIColor, frame: CGRect) {
        self.init(frame: frame)
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    // Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._initControl()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._initControl()
    }

    private func _initControl() {
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true

        //Using a TextField area we can easily modify the control to get user input from this field
        //Calculate font size needed to display 3 numbers
        let str = "0.000" as NSString
        let font = UIFont.systemFontOfSize(DrawingParameters.FontSize.rawValue)
        self.fontSize = str.sizeWithAttributes([NSFontAttributeName:font])

        textField = UITextField(frame: CGRectZero)
        textField?.delegate = self
        textField?.backgroundColor = UIColor.clearColor()
        textField?.textColor = ColorPalette.textGrey
        textField?.textAlignment = .Center
        textField?.font = font

        addSubview(textField!)
    }

    private func _setupControl() {
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width / 2 - DrawingParameters.Padding.rawValue

        // Position the text in the center of the control
        textField?.frame = CGRectMake(frame.width / 2 - fontSize.width / 2, frame.height / 2 - fontSize.height / 2, fontSize.width, fontSize.height)
    }
    
    // MARK: - Touch Tracking

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

        NSNotificationCenter.defaultCenter().postNotificationName("SaveMeasurement", object: nil)
    }

    // MARK: - Drawing

    override func intrinsicContentSize() -> CGSize {

        switch UIDevice.currentDevice().model {
        case "iPad":
            return CGSize(width: 400, height: 400)
        case "iPhone":
            return CGSize(width: 320, height: 320)
        default:
            return CGSize(width: 320, height: 320)
        }
    }
    
    //Use the draw rect to draw the Background, the Circle and the Handle
    override func drawRect(rect: CGRect){
        super.drawRect(rect)

        // Determine if the sizing has been set for the control before drawing.
        if !_setup {
            self._setupControl()
            _setup = true
        }

        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        
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
    
    private func drawTheHandle(ctx:CGContextRef){
        
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

    private func moveHandle(lastPoint: CGPoint) {
        let centerPoint = CGPointMake(self.bounds.size.width / 2.0 - DrawingParameters.LineWidth.rawValue / 2.0, self.bounds.size.height / 2.0 - DrawingParameters.LineWidth.rawValue / 2.0);
        //Calculate the direction from a center point and a arbitrary position.
        let currentAngle: Double = AngleFromNorth(centerPoint, p2: lastPoint, flipped: false);

        //Store the new angle
        if currentAngle == 0 {
            angle = 0
        }
        else {
            angle = 360 - currentAngle
        }

        switch valueFormat {
        case DecimalFormat.None:
            _value = round(angleToValue(angle))
        case DecimalFormat.One:
            _value = round(angleToValue(angle) * 10) / 10
        case DecimalFormat.Two:
            _value = round(angleToValue(angle) * 100) / 100
        case DecimalFormat.Three:
            _value = round(angleToValue(angle) * 1000) / 1000
        default:
            _value = angleToValue(angle)
        }

        //Redraw
        setNeedsDisplay()
    }


    /** Given the angle, get the point position on circumference **/

    private func pointFromAngle(angleInt: Double) -> CGPoint {
        let centerPoint = CGPointMake(self.bounds.size.width / 2.0 - DrawingParameters.LineWidth.rawValue / 2.0, self.bounds.size.height / 2.0 - DrawingParameters.LineWidth.rawValue / 2.0);

        //The point position on the circumference
        //This is too complex for the swift compiler
        let y = Double(radius) * sin(DegreesToRadians(Double(-angleInt))) + Double(centerPoint.y)
        let x = Double(radius) * cos(DegreesToRadians(Double(-angleInt))) + Double(centerPoint.x)

        return CGPoint(x: x, y: y)
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }

    private func angleToValue(angle: Double) -> Double {

        var adjustedRange = Double(angle) * (self.maxValue - self.minValue) / 360

        if self.minValue > 0 {
            adjustedRange += self.minValue
        }

        return adjustedRange
    }

    private func valueToPoint(value: Double) -> CGPoint {
        let adjustedValue: Double
        let measurementRange = self.maxValue - self.minValue

        if self.minValue > 0 {
            adjustedValue = value - self.minValue
        }
        else {
            adjustedValue = value
        }

        let angle = (adjustedValue / measurementRange) * 360

        return pointFromAngle(angle)
    }
}
