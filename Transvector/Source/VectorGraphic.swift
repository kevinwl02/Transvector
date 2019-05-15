//
//  VectorGraphic.swift
//  Transvector
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import UIKit

public class VectorGraphic {
    var paths : [VectorPath]
    
    init () {
        paths = [VectorPath]()
    }
    
    func addPath(path : VectorPath) {
        paths.append(path)
    }
    
    /**
     Creates a view containing renderable vector paths.
     */
    public func vectorView() -> VectorView {
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
            pathLayer.fillColor = nil
        }
        
        return VectorView(parentLayer: parentLayer)
    }
    
    private func colorFloatFromHex(_ hex: UInt32) -> CGFloat {
        return CGFloat(hex & 0xFF) / 255.0
    }
}

public class VectorView: UIView {
    public let parentLayer: CALayer
    private var boundingBox: CGRect?
    private var xOffset: CGFloat = 0
    private var yOffset: CGFloat = 0
    
    /**
     Will scale the graphic based on the view bounds. Default is false.
     */
    public var scaleToFit = false
    
    init(parentLayer: CALayer) {
        self.parentLayer = parentLayer
        super.init(frame: .zero)
        layer.addSublayer(parentLayer)
        setBoundingBox()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == self.layer, let boundingBox = boundingBox {
            var scaleX = boundingBox.width == 0 ? 0 : bounds.width / boundingBox.width
            var scaleY = boundingBox.height == 0 ? 0 : bounds.height / boundingBox.height
            let proportionalScale = min(scaleX, scaleY)
            if !scaleToFit {
                scaleX = proportionalScale
                scaleY = proportionalScale
            }
            parentLayer.transform = CATransform3DMakeScale(scaleX, scaleY, 1)
            
            let diffX = parentLayer.frame.width == 0 ? 0 : (bounds.width - parentLayer.frame.width) / 2
            let diffY = parentLayer.frame.height == 0 ? 0 : (bounds.height - parentLayer.frame.height) / 2
            parentLayer.frame = CGRect(x: diffX + (xOffset * scaleX) / 2, y: diffY + (yOffset * scaleY) / 2, width: parentLayer.frame.width, height: parentLayer.frame.height)
        }
    }
    
    /**
     If the svg is using borders (stroke width), to make a pixel
     perfect render specify stroke sizes and offsets in their original size.
     
     - Parameters:
        - totalExtraX: The total extra width rendered by strokes outside the enclosing
     path
        - totalExtraY: The total extra height rendered by strokes outside the enclosing
     path
        - leftStrokeOffset: The extra width on the left side of the graphic compared to the
     extra width on the right side. If there is more extra width to the right, specify a
     negative number.
        - topStrokeOffset: The extra height on the top side of the graphic compared to the
     extra height on the bottom side. If there is more extra height on the bottom, specify a
     negative number.
     */
    public func setPathVsStrokeCorrection(totalExtraX: CGFloat = 0, totalExtraY: CGFloat = 0, leftStrokeOffset: CGFloat = 0, topStrokeOffset: CGFloat = 0) {
        if let boundingBox = boundingBox {
            let newBox = CGRect(x: 0, y: 0, width: boundingBox.width + totalExtraX, height: boundingBox.height + totalExtraY)
            self.boundingBox = newBox
        }
        self.xOffset = leftStrokeOffset
        self.yOffset = topStrokeOffset
    }
    
    /**
     Animates all paths of this vector view.
     
     Use 'sequential' to queue the animation of each path. By default
     all paths are animated at the same time.
     */
    public func animate(duration: TimeInterval, sequential: Bool = false, completion: (() -> Void)? = nil) {
        let layerCount = parentLayer.sublayers?.count ?? 0
        let sublayers = parentLayer.sublayers ?? []
        if sequential && layerCount > 0 {
            for pathLayer in sublayers {
                pathLayer.isHidden = true
            }
            animatePathLayerSequentially(index: 0, layerCount: layerCount, animDuration: duration / Double(layerCount), completion: completion)
        } else {
            for (i, pathLayer) in sublayers.enumerated() {
                animatePathLayer(pathLayer: pathLayer, animDuration: duration, completion: i == 0 ? completion : nil)
            }
        }
    }
    
    private func animatePathLayerSequentially(index: Int, layerCount: Int, animDuration: TimeInterval, completion: (() -> Void)?) {
        guard let pathLayer = parentLayer.sublayers?[index] else {
            return
        }
        
        pathLayer.isHidden = false
        animatePathLayer(pathLayer: pathLayer, animDuration: animDuration) { [weak self] in
            if index + 1 < layerCount {
                self?.animatePathLayerSequentially(index: index + 1, layerCount: layerCount, animDuration: animDuration, completion: completion)
            } else {
                completion?()
            }
        }
    }
    
    private func animatePathLayer(pathLayer: CALayer, animDuration: TimeInterval, completion: (() -> Void)?) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = animDuration
        CATransaction.setCompletionBlock {
            completion?()
        }
        pathLayer.add(animation, forKey: "VectorGraphic.AddAnimation")
        CATransaction.commit()
    }
    
    private func setBoundingBox() {
        for pathLayer in parentLayer.sublayers ?? [] {
            if let pathLayer = pathLayer as? CAShapeLayer, let pathBox = pathLayer.path?.boundingBoxOfPath {
                if boundingBox == nil {
                    boundingBox = pathBox
                } else {
                    boundingBox = boundingBox?.union(pathBox)
                }
            }
        }
        if let boundingBox = boundingBox {
            let identityBox = CGRect(x: 0, y: 0, width: boundingBox.width, height: boundingBox.height)
            parentLayer.frame = identityBox
            self.boundingBox = identityBox
        }
    }
}
