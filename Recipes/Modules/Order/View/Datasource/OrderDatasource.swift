//
//  OrderDatasource.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import RxSwift

class OrderDatasource: BasicDataSource<ProductDisplayItem, OrderCollectionViewCell> {
    private let cart: Cart

    // MARK: Initializers

    init(cart: Cart) {
        self.cart = cart
    }

    // MARK: Overriden methods

    override func loadContent() {
        loadContentWithCallback { [weak self] loading in
            guard let `self` = self, loading.isCurrent else {
                loading.ignore()
                return
            }

            loading.updateWithContent { datasource in
                let items = self.cart.items.keys.map({ ProductDisplayItem(product: $0, cart: self.cart) })
                (datasource as? OrderDatasource)?.setItems(items)
            }
        }
    }
}
