//
//  Application.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Application
import UIKit.UIWindow

class Application {
    static let shared = Application()

    // MARK: Instance methods

    func configureMainInterface(in window: UIWindow) {
        let cart = Cart()
        let repositoryProvider = RepositoryProvider()
        let navigationController = NavigationController()
        window.rootViewController = navigationController

        let productsWireframe = ProductsWireframe(navigationController: navigationController, repositoryProvider: repositoryProvider, cart: cart)
        productsWireframe.toProductsScreen()
        window.makeKeyAndVisible()
    }
}
