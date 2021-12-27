//
//  File.swift
//  
//
//  Created by Rubens Machion on 23/12/21.
//

import Foundation
import UIKit

extension UIImage {
    public static func image(named: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(named: named, in: Bundle.module, with: nil)
        } else {
            return UIImage(named: named)
        }
    }
}
