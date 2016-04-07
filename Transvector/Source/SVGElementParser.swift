//
//  SVGElementParser.swift
//  Transvector
//
//  Created by Kevin Wong on 4/6/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation
import libxml2

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
    }
    
    static let kPathCommands = NSCharacterSet(charactersInString: "")
    
    //MARK: Public methods
    
    // Path
    class func parsedPathElementWithXMLReader(xmlReader : xmlTextReaderPtr) -> VectorPath? {
        let pathData = String(xmlTextReaderGetAttribute(xmlReader, "d"))
        
        return pathFromPathData(pathData, xmlReader: xmlReader)
    }
    
    // Circle
    class func parsedCircleElementWithXMLReader(xmlReader : xmlTextReaderPtr) -> VectorPath? {
        let centerX = String(xmlTextReaderGetAttribute(xmlReader, "cx")).floatValue()
        let centerY = String(xmlTextReaderGetAttribute(xmlReader, "cy")).floatValue()
        let radius = String(xmlTextReaderGetAttribute(xmlReader, "r")).floatValue()
        
        let pathBuilderResult = SVGPathBuilder().addEllipseWithCenter(centerX, centerY: centerY, radiusX: radius, radiusY: radius).closePath()
        
        return pathFromPathBuilderResult(pathBuilderResult, xmlReader: xmlReader)
    }
    
    // Ellipse
    class func parsedEllipseElementWithXMLReader(xmlReader : xmlTextReaderPtr) -> VectorPath? {
        let centerX = String(xmlTextReaderGetAttribute(xmlReader, "cx")).floatValue()
        let centerY = String(xmlTextReaderGetAttribute(xmlReader, "cy")).floatValue()
        let radiusX = String(xmlTextReaderGetAttribute(xmlReader, "rx")).floatValue()
        let radiusY = String(xmlTextReaderGetAttribute(xmlReader, "ry")).floatValue()
        
        let pathBuilderResult = SVGPathBuilder().addEllipseWithCenter(centerX, centerY: centerY, radiusX: radiusX, radiusY: radiusY).closePath()
        
        return pathFromPathBuilderResult(pathBuilderResult, xmlReader: xmlReader)
    }
    
    // Rect
    class func parsedRectElementWithXMLReader(xmlReader : xmlTextReaderPtr) -> VectorPath? {
        let x = String(xmlTextReaderGetAttribute(xmlReader, "x"))
        let y = String(xmlTextReaderGetAttribute(xmlReader, "y"))
        let width = String(xmlTextReaderGetAttribute(xmlReader, "width"))
        let height = String(xmlTextReaderGetAttribute(xmlReader, "height"))
        let pathData = PathCommand.Move.rawValue.uppercaseString + x + "," + y +
            PathCommand.HLineTo.rawValue + (x + width) +
            PathCommand.VLineTo.rawValue + (y + height) +
            PathCommand.HLineTo.rawValue + x +
            PathCommand.VLineTo.rawValue + y +
            PathCommand.Close.rawValue
        
        return pathFromPathData(pathData, xmlReader: xmlReader)
    }
    
    // Polygon
    class func parsedPolygonElementWithXMLReader(xmlReader : xmlTextReaderPtr) -> VectorPath? {
        let points = String(xmlTextReaderGetAttribute(xmlReader, "points"))
        let pathData = PathCommand.Move.rawValue.uppercaseString + points + PathCommand.Close.rawValue
        
        return pathFromPathData(pathData, xmlReader: xmlReader)
    }
    
    // Attributes
    class func parsedElementAttributesWithXMLReader(xmlReader: xmlTextReaderPtr) -> [String:String] {
        //TODO: Attributes
        return [String:String]()
    }
    
    //MARK: Private methods
    
    private class func pathFromPathData(pathData: String, xmlReader: xmlTextReaderPtr) -> VectorPath? {
        if let pathBuilderResult = builtPathFromPathData(pathData) {
            return pathFromPathBuilderResult(pathBuilderResult, xmlReader: xmlReader)
        } else {
            return nil
        }
    }
    
    private class func pathFromPathBuilderResult(pathBuilderResult: (CGPathRef, VectorPathInfo), xmlReader: xmlTextReaderPtr) -> VectorPath {
        let attributes = parsedElementAttributesWithXMLReader(xmlReader)
        let vectorPath = VectorPath(path: pathBuilderResult.0, pathInfo: pathBuilderResult.1, attributes: attributes)
        
        return vectorPath
    }
    
    private class func builtPathFromPathData(pathData: String) -> (CGPathRef, VectorPathInfo)? {
        let scanner = pathScannerWithPathData(pathData)
        var scannedCommand : NSString?
        let pathBuilder = SVGPathBuilder()
        var builtPath : (CGPathRef, VectorPathInfo)? = nil
        
        while scanner.scanCharactersFromSet(kPathCommands, intoString: &scannedCommand) {
            if let scannedCommand = scannedCommand {
                if scannedCommand.length == 1 {
                    let scannedValues = scannedValuesForScanner(scanner)
                    let isRelative = scannedCommand.lowercaseString == scannedCommand
                    if let scannedCommandEnum = PathCommand(rawValue: String(scannedCommand)) {
                        switch scannedCommandEnum {
                        case .Move:
                            pathBuilder.moveToPointWithValues(scannedValues, relative: isRelative)
                        case .LineTo:
                            pathBuilder.addLineToPointWithValues(scannedValues, relative: isRelative)
                        case .HLineTo:
                            pathBuilder.addHorizontaLineWithValues(scannedValues, relative: isRelative)
                        case .VLineTo:
                            pathBuilder.addVerticalLineWithValues(scannedValues, relative: isRelative)
                        case .CubicBezierCurve:
                            pathBuilder.addCubicCurveWithValues(scannedValues, relative: isRelative)
                        case .CubicBezierSmoothCurve:
                            pathBuilder.addCubicSmoothCurveWithValues(scannedValues, relative: isRelative)
                        case .QuadraticBezierCurve:
                            pathBuilder.addQuadraticCurveWithValues(scannedValues, relative: isRelative)
                        case .QuadraticBezierSmoothCurve:
                            pathBuilder.addQuadraticSmoothCurveWithValues(scannedValues, relative: isRelative)
                        case .EllipticalArc:
                            pathBuilder.addEllipticalArcWithValues(scannedValues, relative: isRelative)
                        case .Close:
                            builtPath = pathBuilder.closePath()
                        }
                    }
                }
            }
        }
        
        return builtPath
    }
    
    private class func scannedValuesForScanner(scanner: NSScanner) -> [Float] {
        var value: Float = 0
        var values = [Float]()
        while scanner.scanFloat(&value) {
            values.append(value)
        }
        
        return values
    }
    
    private class func pathScannerWithPathData(pathData: String) -> NSScanner {
        let scanner = NSScanner(string: pathData)
        let baseCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let skipCharacterSet = pathScannerSkipCharacterSet()
        skipCharacterSet.formUnionWithCharacterSet(baseCharacterSet)
        scanner.charactersToBeSkipped = skipCharacterSet
        
        return scanner
    }
    
    private class func pathScannerSkipCharacterSet() -> NSMutableCharacterSet {
        var characters = ""
        for character in PathCommand.allValues {
            characters += (character.rawValue + character.rawValue.uppercaseString)
        }
        
        return NSMutableCharacterSet(charactersInString: characters)
    }
}
