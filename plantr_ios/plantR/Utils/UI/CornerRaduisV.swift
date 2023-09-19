//
//  CornerRaduisVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 22/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit



class ViewRoundSubViews: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
    }
}

class CircularProgressSubviews: UIView {
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var tracklayer = CAShapeLayer()

    var oneTime = false
    var duration = 1.0
    var progressValue: Float = 0.0
    var radius: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        createCircularPath()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (!oneTime) {
            radius = self.bounds.size.width / 2.0
        
            self.layer.cornerRadius = radius
            createCircularPath()
            self.clipsToBounds = false
            setProgressWithAnimation(duration: duration, value: progressValue)
            oneTime = true
        }
    }
    
    
    var progressColor: UIColor = UIColor.red {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor: UIColor = UIColor.clear {
        didSet {
            tracklayer.strokeColor = trackColor.cgColor
        }
    }
    
    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = radius
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius),
                                      radius: radius, startAngle: CGFloat(-0.5 * Double.pi),
                                      endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        
        tracklayer.path = circlePath.cgPath
        tracklayer.fillColor = UIColor.clear.cgColor
        tracklayer.strokeColor = trackColor.cgColor
        tracklayer.lineWidth = UIDevice.current.userInterfaceIdiom == .pad ? 15 : 10
        tracklayer.strokeEnd = 1.0
        layer.addSublayer(tracklayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = UIDevice.current.userInterfaceIdiom == .pad ? 15 : 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        self.duration = duration
        let previousValue = self.progressValue
        self.progressValue = value
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = previousValue
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateCircle")
    }
}

class CornerRaduisV: UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

class CIRoundedView: UIView {
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
        
        layer.cornerRadius = self.frame.height / 2
        layer.masksToBounds = true
    }
}
