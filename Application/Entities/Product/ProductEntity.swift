//
//  ProductEntity.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain

private extension ProductType {
    init(rawValue: String) {
        switch rawValue {
        case "froyo": self = .froyo
        case "popsicle": self = .popsicle
        case "sundae": self = .sundae
        default: self = .cone
        }
    }
}

struct ProductEntity: Codable {
    let description: String
    let hexColor: String
    let name: String
    let price: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case description = "name2"
        case hexColor = "bg_color"
        case name = "name1"
        case price
        case type
    }
}

extension ProductEntity: DomainTypeConvertible {

    // MARK: DomainTypeConvertible

    func asDomain() -> Product {
        return Product(name: "\(name) \(description)", hexColor: hexColor, price: price, type: ProductType(rawValue: type))
    }
}
