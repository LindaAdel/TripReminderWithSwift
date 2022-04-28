//
//  TextField.swift
//  TripReminder
//
//  Created by Linda adel on 1/11/22.
//

import Foundation
import UIKit
extension UITextField {
    
    func showTextFieldError(placeholderValue:String)
    {
        self.attributedPlaceholder = NSAttributedString(string: placeholderValue, attributes: [
            .foregroundColor: UIColor.red,
            .font: UIFont.boldSystemFont(ofSize: 15.0),
        ])
    }
    
}
extension UILabel {
    func showError(_ message:String){
        
        self.text = message
        self.alpha = 1
    }
}
