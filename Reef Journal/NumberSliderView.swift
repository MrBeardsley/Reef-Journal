//
//  NumberSliderView.swift
//  Reef Journal
//
//  Created by Christopher Harding on 2/24/15.
//  Copyright (c) 2015 Epic Kiwi Interactive. All rights reserved.
//

import UIKit

@IBDesignable class NumberSliderView: UIView {

    @IBInspectable var startColor:UIColor = UIColor.redColor()
    @IBInspectable var endColor:UIColor = UIColor.blueColor()

    @IBInspectable var minValue: Double = 0.0
    @IBInspectable var maxValue: Double = 100.0
    @IBInspectable var minorStep: Double = 1.0
    @IBInspectable var majorStep: Double = 10.0

    #if TARGET_INTERFACE_BUILDER
    override func willMoveToSuperview(newSuperview: UIView?) {

    let slider:BWCircularSlider = BWCircularSlider(startColor:self.startColor, endColor:self.endColor, frame: self.bounds)
    self.addSubview(slider)

    }

    #else
    override func awakeFromNib() {

        super.awakeFromNib()

        // Build the slider
        let slider: NumberSlider = NumberSlider(startColor:self.startColor, endColor:self.endColor, frame: self.bounds)

        // Attach an Action and a Target to the slider
        slider.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)

        // Add the slider as subview of this view
        self.addSubview(slider)

    }
    #endif

    func valueChanged(slider:NumberSlider){
        // Do something with the value...
        print("Value changed \(slider.angle)")
    }
}

