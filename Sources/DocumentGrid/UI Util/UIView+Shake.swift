//
//  File.swift
//  
//
//  Created by Rubens Machion on 27/12/21.
//

import UIKit

// MARK: - UIView Shake
public extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 0.07
        animation.repeatCount = HUGE
        animation.autoreverses = true
        
        let startAngle = (-2) * Double.pi/180.0;
        let stopAngle = -startAngle;
        
        animation.fromValue = NSNumber(value: startAngle)
        animation.toValue =  NSNumber(value: stopAngle)
        
        self.layer.add(animation, forKey: "quivering")
    }
    
    func stopShake() {
        let layer = self.layer;
        layer.removeAnimation(forKey: "quivering")
    }
}

