//
//  SVGPathBuilder.swift
//  Transvector
//
//  Created by Kevin Wong on 4/7/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import UIKit

struct ReflectedLastControlPoint {
    enum CurveType {
        case cubic, quad
    }
    
    let point: CGPoint
    let type: CurveType
}

class SVGPathBuilder {
    private let path = CGMutablePath()
    var closedPath: Bool = true
    var startPoint: CGPoint?
    private var reflectedLastControlPoint: ReflectedLastControlPoint?
    
    @discardableResult
    func moveToPoint(values: [Double], relative: Bool) -> SVGPathBuilder {
        if startPoint != nil {
            closedPath = false
        }
        reflectedLastControlPoint = nil
        iteratePoints(values: values, relative: relative) { point in
            path.move(to: point)
        }
        return self
    }
    
    @discardableResult
    func addLineToPoint(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        iteratePoints(values: values, relative: relative) { point in
            path.addLine(to: point)
        }
        return self
    }
    
    @discardableResult
    func addHorizontaLine(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        for value in values {
            path.addLine(to: relativeHorizontalPoint(x: value, relative: relative))
        }
        return self
    }
    
    @discardableResult
    func addVerticalLine(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        for value in values {
            path.addLine(to: relativeVerticalPoint(y: value, relative: relative))
        }
        return self
    }
    
    @discardableResult
    func addCubicCurve(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        for first in stride(from: 0, to: values.count, by: 6) {
            if values.count <= first + 5 {
                break
            }
            let x1 = values[first]
            let y1 = values[first + 1]
            let x2 = values[first + 2]
            let y2 = values[first + 3]
            let x = values[first + 4]
            let y = values[first + 5]
            let control2 = relativePoint(x: x2, y: y2, relative: relative)
            path.addCurve(to: relativePoint(x: x, y: y, relative: relative), control1: relativePoint(x: x1, y: y1, relative: relative), control2: control2)
            setLastControlPoint(control2, relative: relative, type: .cubic)
        }
        return self
    }
    
    @discardableResult
    func addCubicSmoothCurve(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        for first in stride(from: 0, to: values.count, by: 4) {
            if values.count <= first + 3 {
                break
            }
            let x1 = values[first + 2]
            let y1 = values[first + 3]
            let control1 = (reflectedLastControlPoint != nil && reflectedLastControlPoint?.type == .cubic) ? CGPoint(x: reflectedLastControlPoint!.point.x, y: reflectedLastControlPoint!.point.y) : relativePoint(x: x1, y: y1, relative: relative)
            
            let x2 = values[first]
            let y2 = values[first + 1]
            let x = values[first + 2]
            let y = values[first + 3]
            let control2 = relativePoint(x: x2, y: y2, relative: relative)
            path.addCurve(to: relativePoint(x: x, y: y, relative: relative), control1: control1, control2: control2)
            setLastControlPoint(control2, relative: relative, type: .cubic)
        }
        return self
    }
    
    @discardableResult
    func addQuadraticCurve(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        for first in stride(from: 0, to: values.count, by: 4) {
            if values.count <= first + 3 {
                break
            }
            let x1 = values[first]
            let y1 = values[first + 1]
            let x = values[first + 2]
            let y = values[first + 3]
            let control1 = relativePoint(x: x1, y: y1, relative: relative)
            path.addQuadCurve(to: relativePoint(x: x, y: y, relative: relative), control: control1)
            setLastControlPoint(control1, relative: relative, type: .quad)
        }
        return self
    }
    
    @discardableResult
    func addQuadraticSmoothCurve(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        iteratePoints(values: values, relative: relative) { point in
            let control1 = (reflectedLastControlPoint != nil && reflectedLastControlPoint?.type == .quad) ? CGPoint(x: reflectedLastControlPoint!.point.x, y: reflectedLastControlPoint!.point.y) : point
            path.addQuadCurve(to: point, control: control1)
            setLastControlPoint(control1, relative: relative, type: .quad)
        }
        return self
    }
    
    @discardableResult
    func addEllipticalArc(values: [Double], relative: Bool) -> SVGPathBuilder {
        setStartPoint()
        reflectedLastControlPoint = nil
        return self
    }
    
    @discardableResult
    func addEllipse(centerX: Float, centerY: Float, radiusX: Float, radiusY: Float) -> SVGPathBuilder {
        reflectedLastControlPoint = nil
        let rect = CGRect(x: CGFloat(centerX - radiusX), y: CGFloat(centerY - radiusY), width: CGFloat(radiusX * 2), height: CGFloat(radiusY * 2))
        path.addEllipse(in: rect)
        
        return self
    }
    
    func closePath() -> (CGPath, VectorPathInfo) {
        if let startPoint = startPoint, closedPath, startPoint == path.currentPoint {
            path.closeSubpath()
        }
        let pathInfo = VectorPathInfo(firstPoint: startPoint, lastPoint: path.currentPoint)
        
        return (path, pathInfo)
    }
    
    // MARK: - Private methods
    
    private func relativePoint(x: Double, y: Double, relative: Bool) -> CGPoint {
        if relative {
            return CGPoint(x: Double(path.currentPoint.x) + x, y: Double(path.currentPoint.y) + y)
        } else {
            return CGPoint(x: x, y: y)
        }
    }
    private func relativeHorizontalPoint(x: Double, relative: Bool) -> CGPoint {
        if relative {
            return CGPoint(x: Double(path.currentPoint.x) + x, y: Double(path.currentPoint.y))
        } else {
            return CGPoint(x: x, y: Double(path.currentPoint.y))
        }
    }
    private func relativeVerticalPoint(y: Double, relative: Bool) -> CGPoint {
        if relative {
            return CGPoint(x: Double(path.currentPoint.x), y: Double(path.currentPoint.y) + y)
        } else {
            return CGPoint(x: Double(path.currentPoint.x), y: y)
        }
    }
    
    private func iteratePoints(values: [Double], relative: Bool, output: (CGPoint) -> Void) {
        for valueX in stride(from: 0, to: values.count, by: 2) {
            if values.count <= valueX + 1 {
                break
            }
            let x = values[valueX]
            let y = values[valueX + 1]
            output(relativePoint(x: x, y: y, relative: relative))
        }
    }
    
    private func setLastControlPoint(_ point: CGPoint, relative: Bool, type: ReflectedLastControlPoint.CurveType) {
        let currentPoint = path.currentPoint
        if relative {
            reflectedLastControlPoint = ReflectedLastControlPoint(point: CGPoint(x: currentPoint.x - point.x, y: currentPoint.y - point.y), type: type)
        } else {
            let diffX = point.x - currentPoint.x
            let diffY = point.y - currentPoint.y
            reflectedLastControlPoint = ReflectedLastControlPoint(point: CGPoint(x: currentPoint.x - diffX, y: currentPoint.y - diffY), type: type)
        }
    }
    
    private func setStartPoint() {
        if startPoint == nil {
            startPoint = path.currentPoint
        }
    }
}
