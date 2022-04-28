//
//  Date.swift
//  TripReminder
//
//  Created by Linda adel on 1/18/22.
//

import Foundation
import UIKit

extension NSDate {
    var localizedDescription: String {
        return description(with: NSLocale.current)
    }
}
extension Date {
    var localizedDescription: String {
        return description(with: .current)
    }
}
