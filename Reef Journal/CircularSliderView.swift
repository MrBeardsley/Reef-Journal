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
    
    #if TARGET_INTERFACE_BUILDER
    override func willMoveToSuperview(newSuperview: UIView?) {
        
        let slider = CircularSlider(startColor:self.startColor, endColor:self.endColor, frame: self.bounds)
        self.addSubview(slider)
    
    }
    
    #else
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Build the slider
        let slider = CircularSlider(startColor: self.startColor, endColor: self.endColor, frame: self.bounds)
        
        // Attach an Action and a Target to the slider
        slider.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add the slider as subview of this view
        self.addSubview(slider)

    }
    #endif
    
    func valueChanged(slider: CircularSlider){
        // Do something with the value...
        print("Value changed \(slider.angle)")
    }
}
