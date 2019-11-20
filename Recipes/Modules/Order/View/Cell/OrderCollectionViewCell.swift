//
//  OrderCollectionViewCell.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
}

extension OrderCollectionViewCell: CollectionViewConfigurableCell {

    // MARK: CollectionViewConfigurableCell

    func configure(for product: ProductDisplayItem) {
        nameLabel.text = product.description
        priceLabel.text = product.price
    }
}
