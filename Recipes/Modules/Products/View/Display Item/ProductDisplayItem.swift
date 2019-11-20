//
//  ProductDisplayItem.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import UIKit

private extension ProductType {
    var image: UIImage {
        switch self {
        case .cone: return #imageLiteral(resourceName: "cone")
        case .froyo: return #imageLiteral(resourceName: "froyo")
        case .popsicle: return #imageLiteral(resourceName: "popsicle")
        case .sundae: return #imageLiteral(resourceName: "ice_cream")
        }
    }
}

struct ProductDisplayItem {
    private let cart: Cart

    let color: UIColor
    let image: UIImage
    let description: String
    let name: String
    let price: String
    let product: Product

    // MARK: Initializers

    init(product: Product, cart: Cart) {
        let quantity = cart.quantity(for: product)
        self.cart = cart
        self.color = UIColor(hexString: product.hexColor)
        self.description = "\(product.name)" + (quantity > 0 ? "(\(quantity))" : "")
        self.image = product.type.image
        self.name = product.name.capitalized
        self.price = product.price
        self.product = product
    }

    func quantity() -> Int {
        return cart.quantity(for: product)
    }
}

extension ProductDisplayItem: Equatable {

    // MARK: Equatable

    static func ==(lhs: ProductDisplayItem, rhs: ProductDisplayItem) -> Bool {
        return lhs.product == rhs.product
    }
}
