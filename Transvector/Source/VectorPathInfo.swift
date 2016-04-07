//
//  VectorPathInfo.swift
//  Transvector
//
//  Created by Kevin Wong on 4/7/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class VectorPathInfo {
    var firstPoint: CGPoint
    var lastPoint: CGPoint
    var outDirection: Float
    var inDirection: Float
    
    init (firstPoint: CGPoint, lastPoint: CGPoint, outDirection: Float, inDirection: Float) {
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        self.outDirection = outDirection
        self.inDirection = inDirection
    }
}
