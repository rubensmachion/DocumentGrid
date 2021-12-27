//
//  File.swift
//  
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit

extension UIAlertController {
    
    static public func getAlertController(title: String?,
                                          message: String?,
                                          style: UIAlertController.Style,
                                          actions: [UIAlertAction]) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)
        actions.forEach({
            alert.addAction($0)
        })
        
        return alert
    }
}


extension UIViewController {
    
    public func showAlert(title: String?,
                          message: String?,
                          style: UIAlertController.Style,
                          actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .cancel)]) {
        let alert = UIAlertController.getAlertController(title: title,
                                                         message: message,
                                                         style: style,
                                                         actions: actions)
        
        self.present(alert, animated: true, completion: nil)
    }
}
