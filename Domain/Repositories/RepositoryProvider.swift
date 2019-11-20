//
//  RepositoryProvider.swift
//  Domain
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

public protocol RepositoryProvider {
    func makeProductsRepository() -> ProductsRepository
}
