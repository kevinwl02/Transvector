//
//  SVGParser.swift
//  Transvector
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class SVGParser: NSObject {
    //MARK: Constants
    let kSVGExtension = "svg"
    
    //MARK: Variables
    var groupAttributes: [String:String] = [String:String]()
    var graphic = VectorGraphic()
    var completion: ((VectorGraphic?) -> Void)?
    
    //MARK: Public methods
    
    func parseFileWithName(filename: String, completion: @escaping (VectorGraphic?) -> Void) {
        let filePath = Bundle(for: type(of: self)).url(forResource: filename, withExtension: kSVGExtension)
        
        if let filePath = filePath {
            self.completion = completion
            let reader = XMLParser(contentsOf: filePath)
            reader?.delegate = self
            reader?.parse()
        } else {
            completion(nil)
        }
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

extension SVGParser: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        groupAttributes = [:]
        graphic = VectorGraphic()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completion?(graphic)
        completion = nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == SVGElementParser.kElementTypeGroup {
            groupAttributes = attributeDict
        } else {
            if var parsedElement = parsedElement(elementName: elementName, attributes: attributeDict) {
                parsedElement.attributes = attributeDict
                parsedElement.attributes +! groupAttributes
                graphic.addPath(path: parsedElement)
            }
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == SVGElementParser.kElementTypeGroup {
            groupAttributes = [:]
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
