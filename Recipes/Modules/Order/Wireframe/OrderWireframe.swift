//
//  OrderWireframe.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import UIKit

protocol OrderWireframeInterface {
    func dismissScreen()
    func toOrderScreen()
}

struct OrderWireframe {
    private let cart: Cart
    private let navigationController: NavigationController
    private let storyBoard: UIStoryboard

    // MARK: Initializers

     init(
        navigationController: NavigationController,
        cart: Cart,
        storyBoard: UIStoryboard = UIStoryboard(storyboardName: .main)
        ) {

        self.cart = cart
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
}

extension OrderWireframe: OrderWireframeInterface {

    // MARK: OrderWireframeInterface

    func dismissScreen() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func toOrderScreen() {
        let presenter = OrderPresenter(cart: cart, wireframe: self)
        let viewController: OrderViewController = storyBoard.instantiateViewController()

        viewController.presenter = presenter
        navigationController.present(viewController, animated: true)
    }
}
