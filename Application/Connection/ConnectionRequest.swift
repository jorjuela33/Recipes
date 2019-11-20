//
//  ConnectionRequest.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Alamofire

protocol ConnectionRequestDelegate: class {
    func connectionRequestDidCancel(_ connectionRequest: ConnectionRequest)
    func connectionRequestDidFinish(_ connectionRequest: ConnectionRequest)
    func connectionRequestDidResume(_ connectionRequest: ConnectionRequest)
    func connectionRequestDidSuspend(_ connectionRequest: ConnectionRequest)
}

class ConnectionRequest {
    typealias CompletionCallback = () -> Void
    typealias ResponseDataCallback = (Swift.Result<Data, Error>) -> Void
    typealias ResponseDecodableCallback<T: Decodable> = Swift.Result<T, Error>
    typealias ResponseJSONCallback = (Swift.Result<Any, Error>) -> Void
    
    private let dataRequest: DataRequest
    
    /// A finished request may finish either because it was cancelled or because it successfully
    var completionCallback: CompletionCallback?

    let identifier: ConnectionRequestRegistration
    weak var delegate: ConnectionRequestDelegate?

    /// The data returned by the server.
    var data: Data? {
        return dataRequest.data
    }

    /// The error generated throughout the lifecyle of the request.
    var error: Error? {
        return dataRequest.error
    }

    var httpBody: Data? {
        return dataRequest.request?.httpBody
    }

    var httpMethod: String? {
        return dataRequest.request?.httpMethod
    }

    var metrics: URLSessionTaskMetrics? {
        return dataRequest.metrics
    }
    
    var url: URL? {
        return dataRequest.request?.url
    }
    
    enum ResponseState: String {
        case accountLocked = "afc496"
        case invalidBackupCode = "afc546"
        case invalidEmailOrPassword = "afc506"
        case invalidOtpCode = "afc536"
        case notFound = "000404"
        case tfaEnabled = "afc526"
        case wrongEmailAndPassword = "afc516"
        case unexpected
    }
    
    // MARK: Initializers
    
    init(dataRequest: DataRequest, requestMonitor: RequestMonitor) {
        self.dataRequest = dataRequest
        self.identifier = AtomicNumber.default.getAndIncrement()
        requestMonitor.observeRequestStateUpdates(self, callback: stateCallback)
    }
    
    // MARK: Intance methods
    
    /// Cancels the `Request`.
    func cancel() {
        dataRequest.cancel()
    }
    
    /// returns true if the underlying request is equals
    func matches(_ request: Request) -> Bool {
        return dataRequest === request
    }
    
    /// Adds a handler to be called once the request has finished.
    @discardableResult
    func response<T: Decodable>(_ callback: @escaping (ResponseDecodableCallback<T>) -> Void) -> Self {
        dataRequest.responseDecodable { (response: DataResponse<T, AFError>) in
            switch response.result {
            case let .failure(error): callback(.failure(error))
            case let .success(value): callback(.success(value))
            }
        }

        return self
    }

    /// Adds a handler to be called once the request has finished.
    @discardableResult
    func responseData(_ callback: @escaping ResponseDataCallback) -> Self {
        dataRequest.responseData { response in
            switch response.result {
            case let .failure(error): callback(.failure(error))
            case let .success(value): callback(.success(value))
            }
        }

        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    @discardableResult
    func responseJSON(_ callback: @escaping ResponseJSONCallback) -> Self {
        dataRequest.responseJSON { response in
            switch response.result {
            case let .failure(error): callback(.failure(error))
            case let .success(value): callback(.success(value))
            }
        }

        return self
    }
    
    /// Resume the `Request`.
    @discardableResult
    func resume() -> Self {
        dataRequest.resume()
        return self
    }
    
    /// Suspends the `Request`.
    @discardableResult
    func suspend() -> Self {
        dataRequest.suspend()
        return self
    }
    
    /// Validates the request. Checks for any errors
    /// in the response
    @discardableResult
    func validate() -> Self {
        dataRequest.validate { request, response, data in
            do {
                try ErrorRequestValidator.validate(request, response: response, data: data)
                return .success(Void())
            } catch {
                return .failure(error)
            }
        }
        
        return self
    }
    
    /// Validates the request. Checks for valid status codes
    @discardableResult
    func validateStatusCode() -> Self {
        dataRequest.validate()
        return self
    }
    
    // MARK: Private methods
    
    private func stateCallback(_ state: RequestMonitorState) {
        switch state {
        case .resumed: delegate?.connectionRequestDidResume(self)
        case .suspended: delegate?.connectionRequestDidSuspend(self)
            
        case .canceled:
            completionCallback?()
            delegate?.connectionRequestDidCancel(self)
            
        case .finished:
            completionCallback?()
            delegate?.connectionRequestDidFinish(self)
        }
    }
}

extension ConnectionRequest: Equatable {
    
    // MARK: Equatable
    
    static func == (lhs: ConnectionRequest, rhs: ConnectionRequest) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
