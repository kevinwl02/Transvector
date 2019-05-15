//
//  VectorGraphic.swift
//  Transvector
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class VectorGraphic {
    var paths : [VectorPath]
    
    init () {
        paths = [VectorPath]()
    }
    
    func addPath(path : VectorPath) {
        paths.append(path)
    }
    
    func vectorView(_ view: UIView, animDuration: TimeInterval) -> VectorView {
        let parentLayer = CALayer()
        
        for path in paths {
            let pathLayer = CAShapeLayer()
            pathLayer.path = path.path
            parentLayer.addSublayer(pathLayer)
            
            // Attributes
            if let strokeWidthString = path.attributes[VectorStrokeAttribute.strokeWidth.rawValue], let strokeWidth = Double(strokeWidthString) {
                pathLayer.lineWidth = CGFloat(strokeWidth)
            }
            if let strokeOpacityString = path.attributes[VectorStrokeAttribute.strokeOpacity.rawValue], let strokeOpacity = Float(strokeOpacityString) {
                pathLayer.opacity = strokeOpacity
            }
            if let strokeColor = path.attributes[VectorStrokeAttribute.strokeColor.rawValue] {
                let hexColor = strokeColor.replacingOccurrences(of: "#", with: "")
                var hexIntColor: UInt32 = 0
                Scanner(string: hexColor).scanHexInt32(&hexIntColor)
                let color = UIColor(red: colorFloatFromHex(hexIntColor >> 16), green: colorFloatFromHex(hexIntColor >> 8), blue: colorFloatFromHex(hexIntColor), alpha: 1)
                pathLayer.strokeColor = color.cgColor
            }
            
            // Animate
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = animDuration
            pathLayer.add(animation, forKey: "VectorGraphic.AddAnimation")
        }
        
        return VectorView(parentLayer: parentLayer)
    }
    
    private func colorFloatFromHex(_ hex: UInt32) -> CGFloat {
        return CGFloat(hex & 0xFF) / 255.0
    }
}

class VectorView: UIView {
    let parentLayer: CALayer
    
    init(parentLayer: CALayer) {
        self.parentLayer = parentLayer
        super.init(frame: .zero)
        layer.addSublayer(parentLayer)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeLayers()
    }
    
    private func resizeLayers() {
        parentLayer.frame = bounds
    }
}
