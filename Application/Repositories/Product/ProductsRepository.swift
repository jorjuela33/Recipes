//
//  ProductsRepository.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import RxSwift

class ProductsRepository: Repository {
    private let network: Network

    // MARK: Initializaters

    init(network: Network) {
        self.network = network
    }
}

extension ProductsRepository: Domain.ProductsRepository {

    // MARK: ProductsRepository

    func retrieveProducts() -> Single<[Product]> {
        return Single.create(subscribe: { observer in
            self.beginLoading()
            let connectionRequestRegistration = self.network.retrieveProducts(withCallback: { result in
                switch result {
                case let .failure(error):
                    self.endLoadingStateWithState(.error)
                    observer(.error(error))

                case let .success(currencies):
                    self.endLoadingStateWithState(.contentLoaded)
                    observer(.success(currencies.mapToDomain()))
                }
            })
            return Disposables.create {
                self.network.cancelConnectionRequest(withRegistration: connectionRequestRegistration)
            }
        })
    }
}
