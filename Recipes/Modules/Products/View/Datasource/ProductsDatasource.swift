//
//  ProductsDatasource.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import RxSwift

class ProductsDatasource: BasicDataSource<ProductDisplayItem, ProductCollectionViewCell> {
    private let cart: Cart
    private let disposeBag = DisposeBag()
    private let productsRepository: ProductsRepository

    // MARK: Initializers

    init(cart: Cart, productsRepository: ProductsRepository) {
        self.cart = cart
        self.productsRepository = productsRepository
        super.init()
        noContent = NoContent(title: "No Products.", message: "No Products yet.")
    }

    // MARK: Overriden methods

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.delegate = self
        return cell
    }

    override func loadContent() {
        loadContentWithCallback { [weak self] loading in
            guard let `self` = self, loading.isCurrent else {
                loading.ignore()
                return
            }

            self.productsRepository.retrieveProducts()
                .subscribe(onSuccess: { products in
                    if products.isEmpty {
                        loading.updateWithNoContent { datasource in
                            (datasource as? ProductsDatasource)?.setItems([])
                        }
                    } else {
                        loading.updateWithContent { datasource in
                            (datasource as? ProductsDatasource)?.setItems(products.map({ ProductDisplayItem(product: $0, cart: self.cart) }))
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
}

extension ProductsDatasource: ProductCollectionViewCellDelegate {

    // MARK: ProductCollectionViewCellDelegate

    func productCollectionViewCellDidSelect(_ cell: ProductCollectionViewCell) {
        guard
            /// indexpath
            let indexPath = (cell.superview as? UICollectionView)?.indexPath(for: cell),

            /// selected product
            let product = item(at: indexPath) as ProductDisplayItem?  else { return }

        cart.add(product.product)
    }
}
