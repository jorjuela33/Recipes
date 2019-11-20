//
//  Product.swift
//  Domain
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

public enum ProductType {
    case cone
    case froyo
    case popsicle
    case sundae
}

public struct Product {
    public let hexColor: String
    public let name: String
    public let price: String
    public let type: ProductType

    // MARK: Initializers

    public init(name: String, hexColor: String, price: String, type: ProductType) {
        self.hexColor = hexColor
        self.name = name
        self.price = price
        self.type = type
    }
}

extension Product: Equatable {

    // MARK: Equatable

    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.hexColor == rhs.hexColor &&
               lhs.name == rhs.name &&
               lhs.price == rhs.price &&
               lhs.type == rhs.type
    }
}


extension Product: Hashable {

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name.hashValue ^ price.hashValue)
    }
}
