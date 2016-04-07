//
//  SVGPathBuilder.swift
//  Transvector
//
//  Created by Kevin Wong on 4/7/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class SVGPathBuilder {
    private let path = CGPathCreateMutable()
    
    func moveToPointWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addLineToPointWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addHorizontaLineWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addVerticalLineWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addCubicCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addCubicSmoothCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addQuadraticCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addQuadraticSmoothCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addEllipticalArcWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        return self
    }
    
    func addEllipseWithCenter(centerX: Float, centerY: Float, radiusX: Float, radiusY: Float) -> SVGPathBuilder {
        let rect = CGRectMake(CGFloat(centerX - radiusX), CGFloat(centerY - radiusY), CGFloat(radiusX), CGFloat(radiusY))
        CGPathAddRoundedRect(path, nil, rect, CGFloat(radiusX), CGFloat(radiusY))
        
        return self
    }
    
    func closePath() -> (CGPathRef, VectorPathInfo) {
        
        let firstPoint = CGPointMake(0, 0);
        let lastPoint = CGPointMake(0, 0);
        let outDirection: Float = 0.0
        let inDirection: Float = 0.0
        
        let pathInfo = VectorPathInfo(firstPoint: firstPoint, lastPoint: lastPoint, outDirection: outDirection, inDirection: inDirection)
        
        return (path, pathInfo)
    }
}