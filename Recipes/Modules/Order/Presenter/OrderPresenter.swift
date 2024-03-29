//
//  OrderPresenter.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift

class OrderPresenter {
    private let cart: Cart
    private let datasource: OrderDatasource
    private let disposeBag = DisposeBag()
    private let wireframe: OrderWireframeInterface

    struct Input {
        let newOrder: Driver<Void>
    }

    struct Output {
        let datasource: OrderDatasource
        let total: String
    }

    // MARK: Initializers

    init(cart: Cart, wireframe: OrderWireframeInterface) {
        self.cart = cart
        self.datasource = OrderDatasource(cart: cart)
        self.wireframe = wireframe
    }

    // MARK: Instance methods

    func transform(_ input: Input) -> Output {
        let total = cart.items.compactMap({ $0.key.price.doubleValue() * Double($0.value) }).reduce(0, +)
        datasource.setNeedsLoadContent()

        input.newOrder
            .drive(onNext: { [weak self] in
                self?.cart.removeAll()
                self?.wireframe.dismissScreen()
            })
            .disposed(by: disposeBag)

        return Output(datasource: datasource, total: total.currencyValue())
    }
}
