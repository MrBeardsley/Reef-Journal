//
//  CircularSliderView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/13/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit

struct ColorPalette {
    static let lightBlue = UIColor.cyanColor()
    static let darkBlue = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
    static let textGrey = UIColor(white: 0.5, alpha: 1.0)
}

@IBDesignable class CircularSliderView: UIView {
    
    @IBInspectable var startColor: UIColor = ColorPalette.lightBlue
    @IBInspectable var endColor: UIColor = ColorPalette.darkBlue
    @IBOutlet var detailController: DetailViewController!

    var slider: CircularSlider!
    
    #if TARGET_INTERFACE_BUILDER
    override func willMoveToSuperview(newSuperview: UIView?) {
        
        let tempSlider = CircularSlider(startColor:self.startColor, endColor:self.endColor, frame: self.bounds)
        self.addSubview(tempSlider)
    
    }
    
    #else
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Build the slider
        self.slider = CircularSlider(startColor: self.startColor, endColor: self.endColor, frame: self.bounds)
        
        // Attach an Action and a Target to the slider
        slider.addTarget(detailController, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add the slider as subview of this view
        self.addSubview(slider)
    }
    #endif
}
