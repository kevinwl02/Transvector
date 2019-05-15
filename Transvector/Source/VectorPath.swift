//
//  VectorPath.swift
//  Transvector
//
//  Created by Kevin Wong on 4/6/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import UIKit

enum VectorStrokeAttribute: String {
    case strokeWidth = "stroke-width"
    /**
     Returns a HEX format color e.g. #FFFFFF
     */
    case strokeColor = "stroke"
    case strokeOpacity = "stroke-opacity"
}

struct VectorPath {
    var path: CGPath
    var pathInfo: VectorPathInfo
    var attributes: [String: String]
}
