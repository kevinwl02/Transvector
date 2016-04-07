//
//  VectorGraphic.swift
//  Transvector
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

class VectorGraphic {
    var paths : [VectorPath]
    
    init () {
        paths = [VectorPath]()
    }
    
    func addPath(path : VectorPath) {
        paths.append(path)
    }
}
