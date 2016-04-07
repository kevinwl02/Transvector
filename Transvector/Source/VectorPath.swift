//
//  VectorPath.swift
//  Transvector
//
//  Created by Kevin Wong on 4/6/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class VectorPath {
    var path: CGPathRef
    var pathInfo: VectorPathInfo
    var attributes: [String:String]
    
    init (path: CGPathRef, pathInfo: VectorPathInfo, attributes: [String:String]) {
        self.path = path
        self.pathInfo = pathInfo
        self.attributes = attributes
    }
}