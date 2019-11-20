//
//  RepositoryProvider.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain

public final class RepositoryProvider {
    private let connection: Connection

    // MARK: Initializers

    public init() {
        self.connection = PersistentConnection(server: Server.production, eventMonitors: [LoggingEventMonitor()])
    }
}

extension RepositoryProvider: Domain.RepositoryProvider {

    // MARK: RepositoryProvider

    public func makeProductsRepository() -> Domain.ProductsRepository {
        let network = NetworkManager(connection: connection)
        return ProductsRepository(network: network)
    }
}
