//
//  Double+Transformations.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

extension Double {

    // MARK: Instance methods

    func currencyValue(using formatter: NumberFormatter = numberFormatter) -> String {
        let number = NSNumber(value: self)
        return formatter.string(from: number) ?? "$0.0"
    }
}
