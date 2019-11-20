//
//  Connection.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Alamofire

typealias ConnectionHeaders = [String: String]
typealias ConnectionParameters = [String: Any]
typealias ConnectionRequestRegistration = Int64
typealias ConnectionStatusChangesCallback = (ConnectionStatus) -> Void
typealias JSONObject = [String: Any]

enum Action: String {
    case post = "POST"
    case put = "PUT"
}

enum ConnectionStatus {
    case notReachable
    case reachable

    // MARK: Initializers

    fileprivate init(status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .notReachable, .unknown: self = .notReachable
        case .reachable: self = .reachable
        }
    }
}

protocol Connection {
    var server: Server { get }

    func header(forKey key: String) -> String?
    func removeHeader(forKey key: String)
    func removeObserverWithHandle(_ handle: EventRegistrationHandle)
    func setHeader(_ header: String, forKey key: String)

    @discardableResult
    func delete(_ path: String, headers: [String: String]) -> ConnectionRequest

    @discardableResult
    func get(_ path: String, parameters: ConnectionParameters?, headers: [String: String]) -> ConnectionRequest

    @discardableResult
    func observeReachabilityStatusChanges(_ callback: @escaping ConnectionStatusChangesCallback) -> EventRegistrationHandle

    func send(_ parameters: ConnectionParameters, path: String, action: Action, headers: [String: String]) -> ConnectionRequest
}

extension Connection {

    @discardableResult
    func delete(_ path: String) -> ConnectionRequest {
        return delete(path, headers: [:])
    }

    @discardableResult
    func get(_ path: String) -> ConnectionRequest {
        return get(path, parameters: nil, headers: [:])
    }

    @discardableResult
    func get(_ path: String, parameters: ConnectionParameters?) -> ConnectionRequest {
        return get(path, parameters: parameters, headers: [:])
    }

    @discardableResult
    func get(_ path: String, headers: [String: String]) -> ConnectionRequest {
        return get(path, parameters: nil, headers: headers)
    }

    @discardableResult
    func send(_ parameters: ConnectionParameters, path: String, action: Action) -> ConnectionRequest {
        return send(parameters, path: path, action: action, headers: [:])
    }
}

private class ConnectionDelegate: ConnectionRequestDelegate {
    private let queue = DispatchQueue(label: "com.connectionDelegate", qos: .background)

    let eventMonitors: [RequestEventMonitor]
    let trackedConnectionRequestManager: TrackedConnectionRequestManager

    // MARK: Initializers

    init(eventMonitors: [RequestEventMonitor] = [], trackedConnectionRequestManager: TrackedConnectionRequestManager = .default) {
        self.eventMonitors = eventMonitors
        self.trackedConnectionRequestManager = trackedConnectionRequestManager
    }

    // MARK: ConnectionRequestDelegate

    func connectionRequestDidCancel(_ connectionRequest: ConnectionRequest) {
        queue.async {
            self.trackedConnectionRequestManager.setConnectionRequestInactive(connectionRequest)
            for monitor in self.eventMonitors {
                monitor.queue.async { monitor.requestDidCancel(connectionRequest) }
            }
        }
    }

    func connectionRequestDidFinish(_ connectionRequest: ConnectionRequest) {
        queue.async {
            self.trackedConnectionRequestManager.setConnectionRequestComplete(connectionRequest)
            for monitor in self.eventMonitors {
                monitor.queue.async { monitor.requestDidFinish(connectionRequest) }
            }
        }
    }

    func connectionRequestDidResume(_ connectionRequest: ConnectionRequest) {
        queue.async {
            self.trackedConnectionRequestManager.setConnectionRequestActive(connectionRequest)
            for monitor in self.eventMonitors {
                monitor.queue.async { monitor.requestDidResume(connectionRequest) }
            }
        }
    }

    func connectionRequestDidSuspend(_ connectionRequest: ConnectionRequest) {
        queue.async {
            self.trackedConnectionRequestManager.setConnectionRequestInactive(connectionRequest)
            for monitor in self.eventMonitors {
                monitor.queue.async { monitor.requestDidSuspend(connectionRequest) }
            }
        }
    }
}

final class PersistentConnection: Connection {
    private let callbackQueue = DispatchQueue.main
    private let delegate: ConnectionDelegate
    private let eventCounter = AtomicNumber.default
    private let eventTree = EventTree()
    private let reachabilityManager: NetworkReachabilityManager?
    private let requestMonitor: RequestMonitor
    private let session: Session
    
    private lazy var defaultHTTPHeaders: HTTPHeaders = {
        var defaultHTTPHeaders = HTTPHeaders.default
        defaultHTTPHeaders["Accept"] = "application/json"
        return defaultHTTPHeaders
    }()

    let server: Server

    static let `default` = PersistentConnection(server: Server.production)
    
    // MARK: Initializers
    
    init(
        server: Server,
        eventMonitors: [RequestEventMonitor] = [],
        requestMonitor: RequestMonitor = RequestMonitor(),
        startRequestsImmediately: Bool = true
        ) {
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.multipathServiceType = .handover
        self.delegate = ConnectionDelegate(eventMonitors: eventMonitors)
        self.reachabilityManager = NetworkReachabilityManager(host: "www.apple.com")
        self.requestMonitor = requestMonitor
        self.server = server
        self.session = Session(
            configuration: sessionConfiguration,
            startRequestsImmediately: startRequestsImmediately,
            eventMonitors: [requestMonitor]
        )

        self.reachabilityManager?.startListening(onUpdatePerforming: { [weak self] in
            guard let `self` = self else { return }

            let status = ConnectionStatus(status: $0)
            let events = self.eventTree.applyChange(status)
            events.forEach({ $0.fireOnQueue(self.callbackQueue) })
        })
    }
    
    // MARK: Connection

    /// deletes the remote object
    @discardableResult
    func delete(_ path: String, headers: [String: String]) -> ConnectionRequest {
        return connectionRequest(path, method: .delete, headers: headers)
    }
    
    /// gets the object/s based on the path and parameters
    @discardableResult
    func get(_ path: String, parameters: ConnectionParameters? = nil, headers: [String: String]) -> ConnectionRequest {
        return connectionRequest(path, method: .get, headers: headers, parameters: parameters)
    }

    /// return the value associated to the given header
    func header(forKey key: String) -> String? {
        return defaultHTTPHeaders[key]
    }

    /// observes the reachability changes in the connection
    @discardableResult
    func observeReachabilityStatusChanges(_ callback: @escaping ConnectionStatusChangesCallback) -> EventRegistrationHandle {
        let eventRegistration = DataEventRegistration<ConnectionStatus>(id: eventCounter.getAndIncrement(), callback: callback)
        let connectionStatus: ConnectionStatus = reachabilityManager?.isReachable == true ? .reachable : .notReachable
        callback(connectionStatus)
        eventTree.addEventRegistration(eventRegistration)
        return eventRegistration.id
    }
    
    /// sends the given action to the host
    @discardableResult
    func send(_ parameters: ConnectionParameters, path: String, action: Action, headers: [String: String]) -> ConnectionRequest {
        let method = HTTPMethod(rawValue: action.rawValue)
        return connectionRequest(path, method: method, encoding: JSONEncoding.default, parameters: parameters)
    }

    /// remove the associated header for the given key
    func removeHeader(forKey key: String) {
        defaultHTTPHeaders.remove(name: key)
    }

    /// remove the associated observer for the given handle
    func removeObserverWithHandle(_ handle: EventRegistrationHandle) {
        let eventRegistration = DataEventRegistration<ConnectionStatus>(id: handle)
        let events = eventTree.removeEventRegistration(eventRegistration, cancelError: nil)
        events.forEach({ $0.fireOnQueue(self.callbackQueue) })
    }

    /// sets a new header
    func setHeader(_ header: String, forKey key: String) {
        defaultHTTPHeaders[key] = header
    }

    // MARK: Private methods
    
    private func connectionRequest(
        _ path: String,
        method: HTTPMethod,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String] = [:],
        parameters: ConnectionParameters? = nil
        ) -> ConnectionRequest {

        let headers = HTTPHeaders(defaultHTTPHeaders.dictionary + headers)
        let url = server.connectionURL().appendingPathComponent(path)
        let dataRequest = session.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        let connectionRequest = ConnectionRequest(dataRequest: dataRequest, requestMonitor: requestMonitor)
        connectionRequest.delegate = delegate
        return connectionRequest
    }
}
