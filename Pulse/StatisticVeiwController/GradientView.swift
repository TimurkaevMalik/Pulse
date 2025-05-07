//
//  GradientView.swift
//  Pulse
//
//  Created by Malik Timurkaev on 02.06.2024.
//

import UIKit


class GradientView: UIView {
    
    
    var centerColor: UIColor = .ypLightGreen
    var leftSideColor: UIColor = .ypMediumRed
    var rightSideColor: UIColor = .ypMediumBlue
    
    var startPointX: CGFloat = 0
    var startPointY: CGFloat = 0
    var endPointX: CGFloat = 1
    var endPointY: CGFloat = 1
    
    override func layoutSubviews() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [leftSideColor.cgColor, centerColor.cgColor, rightSideColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.ypWhite.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradientLayer.mask = shape
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        super.layoutSubviews()
    }
}
