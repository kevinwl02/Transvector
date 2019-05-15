//
//  SVGElementParser.swift
//  Transvector
//
//  Created by Kevin Wong on 4/6/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation
import UIKit

class SVGElementParser {
    static let kElementTypeGroup = "g"
    static let kElementTypePath = "path"
    static let kElementTypeCircle = "circle"
    static let kElementTypeEllipse = "ellipse"
    static let kElementTypeRect = "rect"
    static let kElementTypePolygon = "polygon"
    
    enum PathCommand : String {
        case Move = "m"
        case Close = "z"
        case LineTo = "l"
        case HLineTo = "h"
        case VLineTo = "v"
        case CubicBezierCurve = "c"
        case CubicBezierSmoothCurve = "s"
        case QuadraticBezierCurve = "q"
        case QuadraticBezierSmoothCurve = "t"
        case EllipticalArc = "a"
        
        static let allValues = [Move, Close, LineTo, HLineTo, VLineTo,
            CubicBezierCurve, CubicBezierSmoothCurve, QuadraticBezierCurve, QuadraticBezierSmoothCurve,
            EllipticalArc]
        static var pathCommands: String {
            var path = ""
            for value in allValues {
                path += (value.rawValue + value.rawValue.uppercased())
            }
            return path
        }
    }
    
    // MARK: - Public methods
    
    // Path
    class func parsedPathElement(attributes: [String: String]) -> VectorPath? {
        guard let pathData = attributes["d"] else {
            return nil
        }
        
        return pathFromPathData(pathData)
    }
    
    // Circle
    class func parsedCircleElement(attributes: [String: String]) -> VectorPath? {
        guard let centerX = attributes["cx"]?.floatValue(),
            let centerY = attributes["cy"]?.floatValue(),
            let radius = attributes["r"]?.floatValue() else {
                return nil
        }
        
        let pathBuilderResult = SVGPathBuilder().addEllipse(centerX: centerX, centerY: centerY, radiusX: radius, radiusY: radius).closePath()
        
        return pathFromPathBuilderResult(pathBuilderResult)
    }
    
    // Ellipse
    class func parsedEllipseElement(attributes: [String: String]) -> VectorPath? {
        guard let centerX = attributes["cx"]?.floatValue(),
        let centerY = attributes["cy"]?.floatValue(),
        let radiusX = attributes["rx"]?.floatValue(),
            let radiusY = attributes["ry"]?.floatValue() else {
                return nil
        }
        
        let pathBuilderResult = SVGPathBuilder().addEllipse(centerX: centerX, centerY: centerY, radiusX: radiusX, radiusY: radiusY).closePath()
        
        return pathFromPathBuilderResult(pathBuilderResult)
    }
    
    // Rect
    class func parsedRectElement(attributes: [String: String]) -> VectorPath? {
        guard let x = attributes["x"],
            let y = attributes["y"],
            let width = attributes["width"],
            let height = attributes["height"] else {
                return nil
        }
        
        let pathData = PathCommand.Move.rawValue.uppercased() + x + "," + y +
            PathCommand.HLineTo.rawValue + (x + width) +
            PathCommand.VLineTo.rawValue + (y + height) +
            PathCommand.HLineTo.rawValue + x +
            PathCommand.VLineTo.rawValue + y +
            PathCommand.Close.rawValue
        
        return pathFromPathData(pathData)
    }
    
    // Polygon
    class func parsedPolygonElement(attributes: [String: String]) -> VectorPath? {
        guard let points = attributes["points"] else {
            return nil
        }
        
        let pathData = PathCommand.Move.rawValue.uppercased() + points + PathCommand.Close.rawValue
        
        return pathFromPathData(pathData)
    }
    
    //MARK: - Private methods
    
    private class func pathFromPathData(_ pathData: String) -> VectorPath? {
        if let pathBuilderResult = builtPathFromPathData(pathData) {
            return pathFromPathBuilderResult(pathBuilderResult)
        } else {
            return nil
        }
    }
    
    private class func pathFromPathBuilderResult(_ pathBuilderResult: (CGPath, VectorPathInfo)) -> VectorPath {
        let vectorPath = VectorPath(path: pathBuilderResult.0, pathInfo: pathBuilderResult.1, attributes: [String: String]())
        
        return vectorPath
    }
    
    private class func builtPathFromPathData(_ pathData: String) -> (CGPath, VectorPathInfo)? {
        let scanner = pathScannerWithPathData(pathData)
        var scannedCommand : NSString?
        let pathBuilder = SVGPathBuilder()
        var builtPath : (CGPath, VectorPathInfo)? = nil
        
        let scanSet = CharacterSet(charactersIn: PathCommand.pathCommands)
        while scanner.scanCharacters(from: scanSet, into: &scannedCommand) {
            if let scannedCommand = scannedCommand {
                if scannedCommand.length == 1 {
                    let scannedValues = scannedValuesForScanner(scanner)
                    let isRelative = scannedCommand.lowercased == scannedCommand as String
                    if let scannedCommandEnum = PathCommand(rawValue: String(scannedCommand.lowercased)) {
                        switch scannedCommandEnum {
                        case .Move:
                            pathBuilder.moveToPoint(values: scannedValues, relative: isRelative)
                        case .LineTo:
                            pathBuilder.addLineToPoint(values: scannedValues, relative: isRelative)
                        case .HLineTo:
                            pathBuilder.addHorizontaLine(values: scannedValues, relative: isRelative)
                        case .VLineTo:
                            pathBuilder.addVerticalLine(values: scannedValues, relative: isRelative)
                        case .CubicBezierCurve:
                            pathBuilder.addCubicCurve(values: scannedValues, relative: isRelative)
                        case .CubicBezierSmoothCurve:
                            pathBuilder.addCubicSmoothCurve(values: scannedValues, relative: isRelative)
                        case .QuadraticBezierCurve:
                            pathBuilder.addQuadraticCurve(values: scannedValues, relative: isRelative)
                        case .QuadraticBezierSmoothCurve:
                            pathBuilder.addQuadraticSmoothCurve(values: scannedValues, relative: isRelative)
                        case .EllipticalArc:
                            pathBuilder.addEllipticalArc(values: scannedValues, relative: isRelative)
                        case .Close:
                            builtPath = pathBuilder.closePath()
                        }
                    }
                }
            }
        }
        
        if builtPath == nil {
            builtPath = pathBuilder.closePath()
        }
        
        return builtPath
    }
    
    // MARK: - Private methods: Scanner
    
    private class func scannedValuesForScanner(_ scanner: Scanner) -> [Double] {
        var value: Double = 0
        var values = [Double]()
        while scanner.scanDouble(&value) {
            values.append(value)
        }
        
        return values
    }
    
    private class func pathScannerWithPathData(_ pathData: String) -> Scanner {
        let scanner = Scanner(string: pathData)
        let baseCharacterSet = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ","))
        scanner.charactersToBeSkipped = baseCharacterSet
        
        return scanner
    }
}
