//
//  UIView+Extension.swift
//  plantR_ios
//
//  Created by Jean-Sébastien Luciani on 27/03/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit
//
//extension UIView {
//    
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0.0
//        }
//    }
//    
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//    
//    @IBInspectable var borderColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
//    }
//    
//    @IBInspectable var shadowColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.shadowColor!)
//        }
//        set {
//            layer.shadowColor = newValue?.cgColor
//        }
//    }
//    
//    @IBInspectable var shadowOffset: CGSize {
//        get {
//            return layer.shadowOffset
//        }
//        set {
//            layer.shadowOffset = newValue
//        }
//    }
//    
//    @IBInspectable var shadowOpacity: Float {
//        get {
//            return layer.shadowOpacity
//        }
//        set {
//            layer.shadowOpacity = newValue
//        }
//    }
//    
//    @IBInspectable var shadowRadius: CGFloat {
//        get {
//            return layer.shadowRadius
//        }
//        set {
//            layer.shadowRadius = newValue
//        }
//    }
//    
//    public enum innerShadowSide
//    {
//        case all, left, right, top, bottom, topAndLeft, topAndRight, bottomAndLeft, bottomAndRight, exceptLeft, exceptRight, exceptTop, exceptBottom
//    }
//    
//    // define function to add inner shadow
//    public func addInnerShadow(onSide: innerShadowSide, shadowColor: UIColor, shadowSize: CGFloat, cornerRadius: CGFloat = 0.0, shadowOpacity: Float)
//    {
//        // define and set a shaow layer
//        let shadowLayer = CAShapeLayer()
//        shadowLayer.frame = bounds
//        shadowLayer.shadowColor = shadowColor.cgColor
//        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        shadowLayer.shadowOpacity = shadowOpacity
//        shadowLayer.shadowRadius = shadowSize
//        shadowLayer.fillRule = CAShapeLayerFillRule.evenOdd
//        
//        // define shadow path
//        let shadowPath = CGMutablePath()
//        
//        // define outer rectangle to restrict drawing area
//        let insetRect = bounds.insetBy(dx: -shadowSize * 2.0, dy: -shadowSize * 2.0)
//        
//        // define inner rectangle for mask
//        let innerFrame: CGRect = { () -> CGRect in
//            switch onSide
//            {
//            case .all:
//                return CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
//            case .left:
//                return CGRect(x: 0.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 4.0)
//            case .right:
//                return CGRect(x: -shadowSize * 2.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 4.0)
//            case .top:
//                return CGRect(x: -shadowSize * 2.0, y: 0.0, width: frame.size.width + shadowSize * 4.0, height: frame.size.height + shadowSize * 2.0)
//            case.bottom:
//                return CGRect(x: -shadowSize * 2.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 4.0, height: frame.size.height + shadowSize * 2.0)
//            case .topAndLeft:
//                return CGRect(x: 0.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
//            case .topAndRight:
//                return CGRect(x: -shadowSize * 2.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
//            case .bottomAndLeft:
//                return CGRect(x: 0.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
//            case .bottomAndRight:
//                return CGRect(x: -shadowSize * 2.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
//            case .exceptLeft:
//                return CGRect(x: -shadowSize * 2.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height)
//            case .exceptRight:
//                return CGRect(x: 0.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height)
//            case .exceptTop:
//                return CGRect(x: 0.0, y: -shadowSize * 2.0, width: frame.size.width, height: frame.size.height + shadowSize * 2.0)
//            case .exceptBottom:
//                return CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height + shadowSize * 2.0)
//            }
//        }()
//        
//        // add outer and inner rectangle to shadow path
//        shadowPath.addRect(insetRect)
//        shadowPath.addRect(innerFrame)
//        
//        // set shadow path as show layer's
//        shadowLayer.path = shadowPath
//        
//        // add shadow layer as a sublayer
//        layer.addSublayer(shadowLayer)
//        
//        // hide outside drawing area
//        clipsToBounds = true
//    }
//}
//
