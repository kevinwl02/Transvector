//
//  SVGPathBuilder.swift
//  Transvector
//
//  Created by Kevin Wong on 4/7/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class SVGPathBuilder {
    enum Operations {
        case Move, LineTo, HLineTo, VLineTo, CubicCurve, CubicSmoothCurve, QuadraticCurve, QuadraticSmoothCurve, EllipticalArc, Ellipse
        
        func isCurveOperation() -> Bool {
            return (self == CubicCurve ||
                self == CubicSmoothCurve ||
                self == QuadraticCurve ||
                self == QuadraticSmoothCurve)
        }
    }
    
    private let path = CGPathCreateMutable()
    private var lastControlPoint: CGPoint?
    private var lastOperation: Operations?
    
    //Mark: Public methods
    
    func moveToPointWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        if values.count >= 2 {
            let xValue = processedXValue(values[0], isRelative: relative)
            let yValue = processedYValue(values[1], isRelative: relative)
            
            CGPathMoveToPoint(path, nil, xValue, yValue)
            lastOperation = Operations.Move
            
            if values.count > 2 {
                let lineToValues = Array(values[2...values.count])
                addLineToPointWithValues(lineToValues, relative: relative)
            }
        }
        
        return self
    }
    
    func addLineToPointWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for var i = 0; i < values.count; i+=2 {
            if (i + 1 < values.count) {
                let xValue = processedXValue(values[i], isRelative: relative)
                let yValue = processedXValue(values[i+1], isRelative: relative)
                CGPathAddLineToPoint(path, nil, xValue, yValue)
                
                lastOperation = Operations.LineTo
            }
        }
        
        return self
    }
    
    func addHorizontaLineWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for value in values {
            let xValue = processedXValue(value, isRelative: relative)
            CGPathAddLineToPoint(path, nil, xValue, CGPathGetCurrentPoint(path).y)
        }
        
        lastOperation = Operations.HLineTo
        
        return self
    }
    
    func addVerticalLineWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for value in values {
            let yValue = processedYValue(value, isRelative: relative)
            CGPathAddLineToPoint(path, nil, CGPathGetCurrentPoint(path).x, yValue)
        }
        
        lastOperation = Operations.VLineTo
        
        return self
    }
    
    func addCubicCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for var i = 0; i < values.count; i+=6 {
            if (i + 5 < values.count) {
                let controlX1 = processedXValue(values[i], isRelative: relative)
                let controlY1 = processedXValue(values[i+1], isRelative: relative)
                let controlX2 = processedXValue(values[i+2], isRelative: relative)
                let controlY2 = processedXValue(values[i+3], isRelative: relative)
                let xValue = processedXValue(values[i+4], isRelative: relative)
                let yValue = processedXValue(values[i+5], isRelative: relative)
                CGPathAddCurveToPoint(path, nil, controlX1, controlY1, controlX2, controlY2, xValue, yValue)
                
                lastOperation = Operations.CubicCurve
            }
        }
        
        return self
    }
    
    func addCubicSmoothCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for var i = 0; i < values.count; i+=4 {
            if (i + 3 < values.count) {
                let controlPoint1 = firstControlPointForSmoorhCurve()
                let controlX2 = processedXValue(values[i], isRelative: relative)
                let controlY2 = processedXValue(values[i+1], isRelative: relative)
                let xValue = processedXValue(values[i+2], isRelative: relative)
                let yValue = processedXValue(values[i+3], isRelative: relative)
                CGPathAddCurveToPoint(path, nil, controlPoint1.x, controlPoint1.y, controlX2, controlY2, xValue, yValue)
                
                lastOperation = Operations.CubicSmoothCurve
            }
        }
        
        return self
    }
    
    func addQuadraticCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for var i = 0; i < values.count; i+=4 {
            if (i + 3 < values.count) {
                let controlX1 = processedXValue(values[i], isRelative: relative)
                let controlY1 = processedXValue(values[i+1], isRelative: relative)
                let xValue = processedXValue(values[i+2], isRelative: relative)
                let yValue = processedXValue(values[i+3], isRelative: relative)
                CGPathAddQuadCurveToPoint(path, nil, controlX1, controlY1, xValue, yValue)
                
                lastOperation = Operations.QuadraticCurve
            }
        }
        
        return self
    }
    
    func addQuadraticSmoothCurveWithValues(values: [Float], relative: Bool) -> SVGPathBuilder {
        for var i = 0; i < values.count; i+=2 {
            if (i + 1 < values.count) {
                let controlPoint = firstControlPointForSmoorhCurve()
                let xValue = processedXValue(values[i], isRelative: relative)
                let yValue = processedXValue(values[i+1], isRelative: relative)
                CGPathAddQuadCurveToPoint(path, nil, controlPoint.x, controlPoint.y, xValue, yValue)
                
                lastOperation = Operations.QuadraticSmoothCurve
            }
        }
        
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
    
    func closePath() -> (path: CGPathRef, pathInfo: VectorPathInfo) {
        
        let firstPoint = CGPointMake(0, 0);
        let lastPoint = CGPointMake(0, 0);
        let outDirection: Float = 0.0
        let inDirection: Float = 0.0
        
        let pathInfo = VectorPathInfo(firstPoint: firstPoint, lastPoint: lastPoint, outDirection: outDirection, inDirection: inDirection)
        
        return (path, pathInfo)
    }
    
    //MARK: Private methods
    
    func processedXValue(value: Float, isRelative: Bool) -> CGFloat {
        if isRelative {
            return CGPathGetCurrentPoint(path).x + CGFloat(value)
        } else {
            return CGFloat(value)
        }
    }
    
    func processedYValue(value: Float, isRelative: Bool) -> CGFloat {
        if isRelative {
            return CGPathGetCurrentPoint(path).y + CGFloat(value)
        } else {
            return CGFloat(value)
        }
    }
    
    func firstControlPointForSmoorhCurve() -> CGPoint {
        let currentPoint = CGPathGetCurrentPoint(path)
        if lastOperation != nil && lastOperation!.isCurveOperation() {
            let x = currentPoint.x + (currentPoint.x - lastControlPoint!.x)
            let y = currentPoint.y + (currentPoint.y - lastControlPoint!.y)
            
            return CGPointMake(x, y)
        } else {
            return currentPoint
        }
    }
}