//
//  UIColor+Initializers.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: Initializers

    convenience init(hexString: String) {
       let hexString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
       let scanner = Scanner(string: hexString)
       if hexString.hasPrefix("#") {
           scanner.scanLocation = 1
       }

       var color: UInt32 = 0
       scanner.scanHexInt32(&color)
       let mask = 0x000000FF
       let red = CGFloat(Int(color >> 16) & mask) / 255.0
       let green = CGFloat(Int(color >> 8) & mask) / 255.0
       let blue = CGFloat(Int(color) & mask) / 255.0
       self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
