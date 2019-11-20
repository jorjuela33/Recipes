//
//  ProductCollectionViewCell.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import UIKit

protocol ProductCollectionViewCellDelegate: class {
    func productCollectionViewCellDidSelect(_ cell: ProductCollectionViewCell)
}

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var quantityView: UIView!
    weak var delegate: ProductCollectionViewCellDelegate?

    // MARK: Actions

    @IBAction private func selectCell(_ sender: UITapGestureRecognizer) {
        delegate?.productCollectionViewCellDidSelect(self)
    }

    // MARK: Overriden methods

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCell(_:)))
        contentView.addGestureRecognizer(tapGestureRecognizer)
        contentView.layer.cornerRadius = 4
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        productImageView.layer.cornerRadius = productImageView.bounds.height / 2
    }
}

extension ProductCollectionViewCell: CollectionViewConfigurableCell {

    // MARK: CollectionViewConfigurableCell

    func configure(for product: ProductDisplayItem) {
        nameLabel.text = product.name
        priceLabel.text = product.price
        productImageView.backgroundColor = product.color
        productImageView.image = product.image
        quantityLabel.text = "\(product.quantity())"
        quantityView.isHidden = product.quantity() == 0
        contentView.layer.borderWidth = quantityView.isHidden ? 1 : 2
        contentView.layer.borderColor = quantityView.isHidden ? UIColor.lightGray.cgColor : #colorLiteral(red: 0.5098039216, green: 0.8156862745, blue: 0.8235294118, alpha: 1)
    }
}
