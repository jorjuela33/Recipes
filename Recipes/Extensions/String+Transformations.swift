//
//  String+Transformations.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.numberStyle = .currency
    return numberFormatter
}()

extension String {

    // MARK: Instance methods

    func doubleValue(using formatter: NumberFormatter = numberFormatter) -> Double {
        return formatter.number(from: self)?.doubleValue ?? 0
    }
}
