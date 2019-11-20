//
//  ProductsWireframe.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import UIKit

protocol ProductsWireframeInterface {
    func toOrderScreen()
    func toProductsScreen()
}

struct ProductsWireframe {
    private let cart: Cart
    private let navigationController: NavigationController
    private let repositoryProvider: RepositoryProvider
    private let storyBoard: UIStoryboard

    // MARK: Initializers

     init(
        navigationController: NavigationController,
        repositoryProvider: RepositoryProvider,
        cart: Cart,
        storyBoard: UIStoryboard = UIStoryboard(storyboardName: .main)
        ) {

        self.cart = cart
        self.navigationController = navigationController
        self.repositoryProvider = repositoryProvider
        self.storyBoard = storyBoard
    }
}

extension ProductsWireframe: ProductsWireframeInterface {

    // MARK: ProductsWireframeInterface

    func toOrderScreen() {
        let orderWireframe = OrderWireframe(navigationController: navigationController, cart: cart)
        orderWireframe.toOrderScreen()
    }

    func toProductsScreen() {
        let presenter = ProductsPresenter(productsRepository: repositoryProvider.makeProductsRepository(), cart: cart, wireframe: self)
        let viewController: ProductsViewController = storyBoard.instantiateViewController()

        viewController.presenter = presenter
        navigationController.pushViewController(viewController, animated: false)
    }
}
