//
//  SVGParser.swift
//  Transvector
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation
import libxml2

class SVGParser {
    //MARK: Constants
    let kSVGExtension = "svg"
    
    //MARK: Variables
    private var xmlReader: xmlTextReaderPtr?
    
    //MARK: Public methods
    
    func parseFileWithName(filename: String) -> VectorGraphic? {
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: kSVGExtension)
        
        if let filePath = filePath {
            return parseContentString(filePath)
        } else {
            return nil
        }
    }
    
    func parseContentString(contentString: String) -> VectorGraphic? {
        let convertedContentString: NSString = contentString as NSString
        xmlReader = xmlReaderForDoc(UnsafePointer(convertedContentString.UTF8String), nil, nil, 0)
        
        if let xmlReader = xmlReader {
            var groupAttributes: [String:String] = [String:String]()
            let graphic = VectorGraphic()
            
            while xmlTextReaderRead(xmlReader) == 1 {
                let nodeType = UInt32(xmlTextReaderNodeType(xmlReader))
                let elementName = String(xmlTextReaderConstName(xmlReader))
                if strcasecmp(elementName, SVGElementParser.kElementTypeGroup) == 0 {
                    if let parsedGroupAttributes = parsedGroupAttributesForNodeType(nodeType) {
                        groupAttributes = parsedGroupAttributes
                    }
                } else if nodeType == XML_READER_TYPE_ELEMENT.rawValue {
                    if let parsedElement = parsedElementWithName(elementName, nodeType: nodeType) {
                        parsedElement.attributes +! groupAttributes
                        graphic.addPath(parsedElement)
                    }
                }
            }
            
            xmlFreeTextReader(xmlReader)
            self.xmlReader = nil
            
            return graphic
        }
        
        return nil
    }
    
    //MARK: Private methods
    
    private func parsedElementWithName(elementName: String, nodeType: UInt32) -> VectorPath? {
        if nodeType == XML_READER_TYPE_ELEMENT.rawValue {
            switch elementName {
            case SVGElementParser.kElementTypePath:
                return SVGElementParser.parsedPathElementWithXMLReader(xmlReader!)
            case SVGElementParser.kElementTypeCircle:
                return SVGElementParser.parsedCircleElementWithXMLReader(xmlReader!)
            case SVGElementParser.kElementTypeEllipse:
                return SVGElementParser.parsedEllipseElementWithXMLReader(xmlReader!)
            case SVGElementParser.kElementTypeRect:
                return SVGElementParser.parsedPolygonElementWithXMLReader(xmlReader!)
            default:
                return nil
            }
        }
        
        return nil
    }
    
    private func parsedGroupAttributesForNodeType(nodeType: UInt32) -> [String:String]? {
        if nodeType == XML_READER_TYPE_ELEMENT.rawValue {
            return SVGElementParser.parsedElementAttributesWithXMLReader(xmlReader!)
        } else if nodeType == XML_READER_TYPE_END_ELEMENT.rawValue {
            return [String:String]()
        }
        
        return nil
    }
}

//MARK: Operator Override

/**
 * Adds values from the right operand that don't exist in the left operand into the left operand.
 */
infix operator +! {
}

func +! <KeyType, ValueType> (inout left: [KeyType:ValueType], right: [KeyType:ValueType]) {
    for entry in right {
        if (left[entry.0] == nil) {
            left[entry.0] = entry.1
        }
    }
}
