//
//  RequestMonitor.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Alamofire

enum RequestMonitorState {
    case canceled
    case finished
    case resumed
    case suspended
}

class RequestMonitor: ClosureEventMonitor {
    private let lock = NSLock()
    private var observers: [RequestMonitorObserver] = []

    // MARK: Initializers

    init() {
        super.init(queue: DispatchQueue(label: "com.requestMonitor"))
    }

    // MARK: Instance methods

    func observeRequestStateUpdates(
        _ connectionRequest: ConnectionRequest,
        callback: @escaping RequestMonitorObserver.RequestMonitorCallback
        ) {

        queue.sync {
            let observer = RequestMonitorObserver(connectionRequest: connectionRequest, callback: callback)
            observers.append(observer)
        }
    }

    // MARK: Overrided methods

    override func requestDidCancel(_ request: Request) {
        super.requestDidCancel(request)
        notify(request, newState: .canceled)
        removeObserver(for: request)
    }

    override func requestDidFinish(_ request: Request) {
        super.requestDidFinish(request)
        notify(request, newState: .finished)
        removeObserver(for: request)
    }

    override func requestDidResume(_ request: Request) {
        super.requestDidResume(request)
        notify(request, newState: .resumed)
    }

    override func requestDidSuspend(_ request: Request) {
        super.requestDidSuspend(request)
        notify(request, newState: .suspended)
    }

    // MARK: Private methods

    private func notify(_ request: Request, newState state: RequestMonitorState) {
        lock.lock()
        let observers = self.observers.filter({ $0.connectionRequest.matches(request) })
        lock.unlock()
        observers.forEach({ $0.notify(state) })
    }

    private func removeObserver(for request: Request) {
        lock.lock()
        observers = observers.filter({ !$0.connectionRequest.matches(request) })
        lock.unlock()
    }
}
