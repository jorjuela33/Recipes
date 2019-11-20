//
//  RequestEventMonitor.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

func +<T>(lhs: [String: T], rhs: [String: T]) -> [String: T] {
    return lhs.merging(rhs, uniquingKeysWith: { _, value in return value })
}

private extension ConnectionRequest {
    var metadata: [String: Any] {
        return ["requestInfo": [
            "connectionIdentifier": identifier,
            "method": httpMethod ?? "",
            "path": url?.path ?? ""]
        ]
    }
}

protocol RequestEventMonitor {
    /// The `DispatchQueue` onto which the connection will dispatch events.
    var queue: DispatchQueue { get }

    /// Event called  when the `Request` has been cancelled.
    func requestDidCancel(_ request: ConnectionRequest)

    /// Event called  when the `Request` has finished.
    func requestDidFinish(_ request: ConnectionRequest)

    /// Event called  when the `Request` has been resumed.
    func requestDidResume(_ request: ConnectionRequest)

    /// Event called  when the `Request` has been suspended.
    func requestDidSuspend(_ request: ConnectionRequest)
}

struct LoggingEventMonitor: RequestEventMonitor {
    let queue = DispatchQueue(label: "com.logging.monitor")

    // MARK: RequestEventMonitor

    func requestDidCancel(_ request: ConnectionRequest) {
        print("com.connection.request.cancelled data: \(request.metadata)")
    }

    func requestDidFinish(_ request: ConnectionRequest) {
        if let error = request.error {
            let metadata = request.metadata + ["error": error.localizedDescription]
            print("com.connection.request.error data: \(metadata)")
        } else if let data = request.data {
            let metadata = request.metadata + ["response": String(data: data, encoding: .utf8) ?? ""]
            print("com.connection.request.finished data: \(metadata)")
        }
    }

    func requestDidResume(_ request: ConnectionRequest) {
        print("com.connection.request.resumed data: \(request.metadata)")
    }

    func requestDidSuspend(_ request: ConnectionRequest) {
        print("com.connection.request.suspend data: \(request.metadata)")
    }
}
