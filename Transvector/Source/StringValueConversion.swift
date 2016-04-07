//
//  StringValueConversion.swift
//  Transvector
//
//  Created by Kevin Wong on 4/7/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import Foundation

extension String {
    func floatValue() -> Float {
        return (self as NSString).floatValue
    }
}
