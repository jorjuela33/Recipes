//
//  ProductsPresenter.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift

class Cart {
    private(set) var items: [Product: Int] = [:] {
        didSet {
            changesCallback?()
        }
    }

    /// not ideal because is 1-1 but there is no much time for a better implementation
    var changesCallback: (() -> Void)?
    var products: Int {
        return items.values.reduce(0, +)
    }

    // MARK: Instance methods

    func add(_ product: Product) {
        var quantity = items[product] ?? 0
        quantity += 1
        if quantity >= 3 {
            items.removeValue(forKey: product)
        } else {
            items[product] = quantity
        }
    }

    func removeAll() {
        items.removeAll()
    }

    func quantity(for product: Product) -> Int {
        return items[product] ?? 0
    }
}

class ProductsPresenter {
    private let cart: Cart
    private let datasource: ProductsDatasource
    private let disposeBag = DisposeBag()
    private let wireframe: ProductsWireframeInterface

    struct Input {
        let order: Driver<Void>
        let pullDownToRefresh: Driver<Void>
    }

    struct Output {
        let datasource: ProductsDatasource
        let error: Driver<Message>
        let orderHidden: Driver<Bool>
        let orderTitle: Driver<String>
    }

    // MARK: Initializers

    init(productsRepository: ProductsRepository, cart: Cart, wireframe: ProductsWireframeInterface) {
        self.cart = cart
        self.datasource = ProductsDatasource(cart: cart, productsRepository: productsRepository)
        self.wireframe = wireframe
    }

    // MARK: Instance methods

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let orderHidden = BehaviorRelay(value: true)
        let orderTitle = BehaviorRelay(value: "Order")

        datasource.setNeedsLoadContent()
        cart.changesCallback = { [weak self] in
            let products = self?.cart.products ?? 0
            let pluralized = products > 1 ? "s" : ""
            orderHidden.accept(products == 0)
            orderTitle.accept("Order \(products) item\(pluralized)")
        }

        input.order.drive(onNext: wireframe.toOrderScreen).disposed(by: disposeBag)

        input.pullDownToRefresh
            .drive(onNext: { [weak self] in
                self?.datasource.setNeedsLoadContent()
            })
            .disposed(by: disposeBag)

        return Output(
            datasource: datasource,
            error: errorTracker.map(ErrorBuilder.create),
            orderHidden: orderHidden.asDriver(),
            orderTitle: orderTitle.asDriver()
        )
    }
}
