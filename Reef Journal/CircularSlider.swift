//
//  CircularSlider.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/13/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit


@IBDesignable class CircularSlider: UIControl {

    // MARK: - Properties

    // Colors
    @IBInspectable var startColor: UIColor = UIColor.blackColor()
    @IBInspectable var endColor: UIColor = UIColor.blackColor()
    @IBInspectable var lineColor: UIColor = UIColor.blackColor()

    // Control Value
    var maxValue: Double = 0
    var minValue: Double = 0
    var valueFormat: String = DecimalFormat.None
    var value: Double {
        get {
            switch valueFormat {
            case DecimalFormat.None:
                return _value
            case DecimalFormat.One:
                return round(_value * 10) / 10
            case DecimalFormat.Two:
                return round(_value * 100) / 100
            case DecimalFormat.Three:
                return round(_value * 1000) / 1000
            default:
                return _value
            }
        }

        set {
            angle = angleFromValue(newValue)
            handlePosition = pointFromAngle(angle)
            switch newValue {
            case let x where x < minValue:
                _value = minValue
                break
            case let x where x > maxValue:
                _value = maxValue
                break
            default:
                _value = newValue
            }
            
            setNeedsDisplay()
        }
    }

    // MARK: - Private Properties
    
    private var _value: Double = 0 {
        didSet {
            valueLabel.text = String(format: self.valueFormat, _value)
        }
    }

    private var handlePosition = CGPointZero
    private var shouldMoveHandle = false
    private var textField: UITextField?
    private var valueLabel = UILabel()
    private var fontSize: CGSize = CGSizeZero
    private var radius: CGFloat = 100
    private var angle: Double = 0

    // MARK: - Init/Deinit

    convenience init(startColor: UIColor, endColor: UIColor, frame: CGRect) {
        self.init(frame: frame)
        
        self.startColor = startColor
        self.endColor = endColor
        _initControl()
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

        valueLabel.textColor = UIColor.grayColor()
        valueLabel.textAlignment = .Center
        
        addSubview(valueLabel)
    }
    
    // MARK: - Control Layout

    func layoutControl() {
        radius = intrinsicContentSize().width / 2 - DrawingConstants.padding
        handlePosition = pointFromAngle(angle)

        // Position the text in the center of the control
        let circleCenter = CGPoint(x: intrinsicContentSize().width / 2.0, y: intrinsicContentSize().height / 2.0)
        let fontSize = fontSizeForWidth(intrinsicContentSize().width)
        let sizeString = NSString(string: "0.000")
        let valueFont = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightLight)
        let labelSize = sizeString.sizeWithAttributes([NSFontAttributeName : valueFont])
        
        valueLabel.font = valueFont
        valueLabel.frame = CGRect(x: circleCenter.x - labelSize.width / 2, y: circleCenter.y - labelSize.height / 2, width: labelSize.width, height: labelSize.height)

        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    override func intrinsicContentSize() -> CGSize {
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
                  mainWindow = appDelegate.window else { return CGSizeZero }
        
        let traits = mainWindow.traitCollection
        
        switch (traits.horizontalSizeClass, traits.verticalSizeClass) {
        case (.Compact, .Unspecified):
            return CGSize(width: 300, height: 300)
        case (.Regular, .Compact):
            return CGSize(width: 300, height: 300)
        case (.Regular, .Regular):
            return CGSize(width: 400, height: 400)
        default:
            return CGSize(width: 300, height: 300)
        }
    }
    
    // MARK: - Touch Tracking

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        shouldMoveHandle = isPointInHandle(touch.locationInView(self))
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        let lastPoint = touch.locationInView(self)
        if shouldMoveHandle {
            let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
            angle = 360.0 - angleFromPoints(center, p2: lastPoint )
            handlePosition = pointFromAngle(angle)
            _value = valueFromAngle(angle)
            self.setNeedsDisplay()
        }

        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        shouldMoveHandle = false
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

    // MARK: - Drawing
    
    override func drawRect(rect: CGRect){
        super.drawRect(rect)

        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        /** Draw the Background **/
        CGContextSaveGState(ctx)
        
        CGContextAddArc(ctx, CGFloat(bounds.width / 2.0), CGFloat(bounds.height / 2.0), radius, 0, CGFloat(M_PI * 2), 0)
        lineColor.set()
        
        CGContextSetLineWidth(ctx, backgroundLindeWidthForWidth(bounds.width))
        CGContextSetLineCap(ctx, CGLineCap.Butt)
        
        CGContextDrawPath(ctx, CGPathDrawingMode.Stroke)
        
        CGContextRestoreGState(ctx)
        
        /** Draw the circle **/
        
        /** Create THE MASK Image **/
        UIGraphicsBeginImageContext(CGSize(width: bounds.width, height: bounds.height))

        let imageCtx = UIGraphicsGetCurrentContext()
        CGContextAddArc(imageCtx, CGFloat(bounds.width / 2.0), CGFloat(bounds.height / 2.0), radius, 0, CGFloat(DegreesToRadians(Double(angle))), 0)
        UIColor.redColor().set()
        
        //Use shadow to create the Blur effect
        CGContextSetShadowWithColor(imageCtx, CGSizeZero, CGFloat(15), UIColor.blackColor().CGColor)
       
        //define the path
        CGContextSetLineWidth(imageCtx, lineWidthForWidth(bounds.width))
        CGContextDrawPath(imageCtx, CGPathDrawingMode.Stroke)
        
        //save the context content into the image mask
        let mask: CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())!
        UIGraphicsEndImageContext()
        
        /** Clip Context to the mask **/
        CGContextSaveGState(ctx)
        
        CGContextClipToMask(ctx, bounds, mask)
        
        
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
        let startPoint = CGPointMake(rect.midX, rect.minY)
        let endPoint = CGPointMake(rect.midX, rect.maxY)
        
        // Draw the gradient
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, CGGradientDrawingOptions())
        CGContextRestoreGState(ctx)

        /* Draw the handle */
        drawHandle(ctx)
    }
    
    private func drawHandle(ctx: CGContextRef) {
        CGContextSaveGState(ctx)
        CGContextSetShadowWithColor(ctx, CGSize(width: 0, height: 0), 3, UIColor.blackColor().CGColor)
        
        let rad = handleRadiusForWidth(bounds.width)

        UIColor(white:1.0, alpha:DrawingConstants.handleAlpha).set()
        CGContextFillEllipseInRect(ctx, CGRect(x: handlePosition.x - rad / 2.0, y: handlePosition.y - rad / 2.0, width: rad, height: rad))
        CGContextRestoreGState(ctx)
    }
    
    // MARK: - Private Helper Functions

    private func angleFromPoints(p1: CGPoint, p2: CGPoint) -> Double {
        guard p1 != p2 else { return 0.0 }
        
        var v = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag: CGFloat = Square(Square(v.x) + Square(v.y))
        var result: Double = 0.0
        v.x /= vmag
        v.y /= vmag
        let radians = Double(atan2(v.y, v.x))
        result = RadiansToDegrees(radians)
        
        return (result >= 0  ? result : result + 360.0)
    }
    
    private func pointFromAngle(angle: Double) -> CGPoint {
        let circleCenter = CGPoint(x: intrinsicContentSize().width / 2.0, y: intrinsicContentSize().height / 2.0)
        
        //The point position on the circumference
        let x = Double(radius) * cos(DegreesToRadians(angle)) + Double(circleCenter.x)
        let y = Double(radius) * sin(DegreesToRadians(-angle)) + Double(circleCenter.y)

        return CGPoint(x: x, y: y)
    }

    private func valueFromAngle(angle: Double) -> Double {
        let value = (angle / 360.0) * (self.maxValue - self.minValue)

        return minValue > 0 ? value + minValue : value
    }
    
    private func angleFromValue(value: Double) -> Double {
        
        switch value {
        case let x where x <= self.minValue:
            return 0.0
        case let x where x >= self.maxValue:
            return 360.0
        case let x where x > self.minValue && x < self.maxValue:
            let range = maxValue - minValue
            let adjusted = x - minValue
            return adjusted / range * 360.0
        default:
            return 0.0
        }
    }
    
    private func isPointInHandle(point: CGPoint) -> Bool {
        let rad = handleRadiusForWidth(bounds.width)
        let radiusSquared = Square(rad)
        let xCom = Square(point.x - handlePosition.x)
        let yCom = Square(point.y - handlePosition.y)
        
        return (xCom + yCom < radiusSquared)
    }
    
    private func fontSizeForWidth(width: CGFloat) -> CGFloat {
        
        switch width {
        case let w where w < 295.0:
            return DrawingConstants.fontSizeSmall
        case let w where w < 400.0:
            return DrawingConstants.fontSizeMedium
        default:
            return DrawingConstants.fontSizeLarge
            
        }
    }
    
    private func lineWidthForWidth(width: CGFloat) -> CGFloat {
        return width < 295.0 ? DrawingConstants.lineWidthSmall : DrawingConstants.lineWidth
    }
    
    private func backgroundLindeWidthForWidth(width: CGFloat) -> CGFloat {
        return width < 295.0 ? DrawingConstants.backgroundLineWidthSmall : DrawingConstants.backgroundLineWidth
    }
    
    private func handleRadiusForWidth(width: CGFloat) -> CGFloat {
        return width < 295.0 ? DrawingConstants.handleRadiusSmall : DrawingConstants.handleRadius
    }
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

// MARK: - Constants

private struct DrawingConstants {
    static let handleRadius: CGFloat = 40.0
    static let handleRadiusSmall: CGFloat = 25.0
    static let handleAlpha: CGFloat = 0.8
    static let padding: CGFloat = 40.0
    static let lineWidth: CGFloat = 40.0
    static let lineWidthSmall: CGFloat = 25.0
    static let backgroundLineWidthSmall: CGFloat = 30.0
    static let backgroundLineWidth: CGFloat = 48.0
    static let fontSizeSmall: CGFloat = 36.0
    static let fontSizeMedium: CGFloat = 60.0
    static let fontSizeLarge: CGFloat = 84.0
}

struct DecimalFormat {
    static let None = "%.0f"
    static let One = "%.1f"
    static let Two = "%.2f"
    static let Three = "%.3f"
}
