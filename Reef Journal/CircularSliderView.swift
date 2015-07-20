//
//  CircularSliderView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/13/15.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

@IBDesignable class CircularSliderView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.blueColor()
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
