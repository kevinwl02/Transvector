//
//  SVGParser.swift
//  Transvector
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

/**
 SVG parser into computable / renderable vector data.
 Supports only Vector strokes. (e.g. no fill, masks, etc.)
 */
public class SVGStrokeParser: NSObject {
    //MARK: Constants
    let kSVGExtension = "svg"
    
    //MARK: Variables
    var groupAttributes: [String:String] = [String:String]()
    var graphic = VectorGraphic()
    var completion: ((VectorGraphic?) -> Void)?
    var stackedGroupAttributes = [[String: String]]()
    
    //MARK: Public methods
    
    /**
     Returns a vector view from a SVG file. The vector view
     contains renderable SVG data.
     */
    public func vectorView(filename: String, completion: @escaping (VectorView?) -> Void) {
        resetState()
        vectorGraphic(filename: filename) { graphic in
            completion(graphic?.vectorView())
        }
    }
    
    /**
     Returns a vector graphic from a SVG file. A vector graphic
     contains the data representation of the SVG data.
     */
    public func vectorGraphic(filename: String, completion: @escaping (VectorGraphic?) -> Void) {
        resetState()
        let filePath = Bundle.main.url(forResource: filename, withExtension: kSVGExtension)
        if let filePath = filePath {
            self.completion = completion
            let reader = XMLParser(contentsOf: filePath)
            reader?.delegate = self
            reader?.parse()
        } else {
            completion(nil)
        }
    }
    
    public func resetState() {
        graphic = VectorGraphic()
        completion = nil
        stackedGroupAttributes = [[:]]
    }
    
    //MARK: Private methods
    
    private func parsedElement(elementName: String, attributes: [String: String]) -> VectorPath? {
        switch elementName {
        case SVGElementParser.kElementTypePath:
            return SVGElementParser.parsedPathElement(attributes: attributes)
        case SVGElementParser.kElementTypeCircle:
            return SVGElementParser.parsedCircleElement(attributes: attributes)
        case SVGElementParser.kElementTypeEllipse:
            return SVGElementParser.parsedEllipseElement(attributes: attributes)
        case SVGElementParser.kElementTypeRect:
            return SVGElementParser.parsedPolygonElement(attributes: attributes)
        default:
            return nil
        }
    }
}

extension SVGStrokeParser: XMLParserDelegate {
    public func parserDidStartDocument(_ parser: XMLParser) {
        groupAttributes = [:]
        graphic = VectorGraphic()
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        completion?(graphic)
        completion = nil
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == SVGElementParser.kElementTypeGroup {
            addGroupAttributes(attributes: attributeDict)
        } else {
            if var parsedElement = parsedElement(elementName: elementName, attributes: attributeDict) {
                parsedElement.attributes = attributeDict
                parsedElement.attributes +! groupAttributes
                graphic.addPath(path: parsedElement)
            }
        }
    }
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == SVGElementParser.kElementTypeGroup {
            removeLastGroupAttributes()
        }
    }
    private func addGroupAttributes(attributes: [String: String]) {
        stackedGroupAttributes.append(attributes)
        recalculateGroupAttributes()
    }
    private func removeLastGroupAttributes() {
        if stackedGroupAttributes.count == 0 { return }
        
        stackedGroupAttributes.removeLast()
        recalculateGroupAttributes()
    }
    private func recalculateGroupAttributes() {
        groupAttributes = [:]
        for attributes in stackedGroupAttributes {
            groupAttributes.merge(attributes, uniquingKeysWith: { (_, new) in new })
        }
    }
}

//MARK: Operator Override

/**
 * Adds values from the right operand that don't exist in the left operand into the left operand.
 */
infix operator +!

func +! <KeyType, ValueType> ( left: inout [KeyType:ValueType], right: [KeyType:ValueType]) {
    for entry in right {
        if (left[entry.0] == nil) {
            left[entry.0] = entry.1
        }
    }
}
