//
//  Network.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain

typealias RetrieveCallback<T> = (Result<T, Error>) -> Void
typealias VoidCallback = (Result<Void, Error>) -> Void

struct CurrenciesResponse: Codable {
    let success: Bool
    let date: String
    let rates: [String: Double]
    let timestamp: TimeInterval
}

protocol Network {
    func cancelConnectionRequest(withRegistration registration: ConnectionRequestRegistration)
    func header(forKey key: String) -> String?
    func retrieveProducts(withCallback callback: @escaping RetrieveCallback<[ProductEntity]>) -> ConnectionRequestRegistration
    func setHeader(_ value: String, forKey key: String)
}

final class NetworkManager: Network {
    private let connection: Connection
    private let connectionTree = ConnectionTree()
    private static let queue = DispatchQueue(label: "com.network.queue")

    // MARK: Initializers

    init(connection: Connection) {
        self.connection = connection
    }

    // MARK: Network

    /// cancels the request associated to the registration
    func cancelConnectionRequest(withRegistration registration: ConnectionRequestRegistration) {
        connectionTree.removeConnectionRequest(withRegistration: registration)
    }

    /// return the value associated to the given header
    func header(forKey key: String) -> String? {
        return connection.header(forKey: key)
    }

    /// retrieves all the products from the remote store
    func retrieveProducts(withCallback callback: @escaping RetrieveCallback<[ProductEntity]>) -> ConnectionRequestRegistration {
        let connectionRequest = connection.get("products").response(callback).validate()
        enqueueConnectionRequest(connectionRequest)
        return connectionRequest.identifier
    }

    /// sets the header for all the requests
    func setHeader(_ value: String, forKey key: String) {
        connection.setHeader(value, forKey: key)
    }

    // MARK: Private methods

    private func enqueueConnectionRequest(_ connectionRequest: ConnectionRequest) {
        connectionRequest.completionCallback = { [weak self] in
            self?.cancelConnectionRequest(withRegistration: connectionRequest.identifier)
        }

        NetworkManager.queue.async {
            self.connectionTree.addConnectionRequest(connectionRequest)
        }
    }
}
