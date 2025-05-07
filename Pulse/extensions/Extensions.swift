//
//  Extensious.swift
//  Pulse
//
//  Created by Malik Timurkaev on 12.04.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        
        for subview in subviews {
            addSubview(subview)
        }
    }
}

extension UIScrollView {
    func addSubviewsToScrollView(_ subviews: [UIView]){
        
        for subview in subviews {
            addSubview(subview)
        }
    }
}

extension Date {
    func startOfWeek(using calendar: Calendar) -> Date {
        
        guard let sunday = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date else {
            return Date()
        }
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        
        guard let monday = calendar.date(byAdding: dateComponents, to: sunday) else {
            return Date()
        }
        
        return monday
    }
    
    func getDefaultDateWith(formatter: DateFormatter) -> Date? {
        
        let stringDate = formatter.string(from: self)
        guard let date = formatter.date(from: stringDate) else {
            return nil
        }
        return date
    }
}

extension NSMutableAttributedString {
    
    func setColor(_ color: UIColor, forText: String) {
        
        let range: NSRange = self.mutableString.range(of: forText, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}

extension UIAlertAction {
    
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
