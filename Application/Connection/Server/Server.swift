//
//  Server.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

struct Server {
    let host: String
    let isSecure: Bool
    let path: String

    static let production = Server(host: "gl-endpoint.herokuapp.com", isSecure: true)
    static let staging = Server(host: "gl-endpoint.herokuapp.com", isSecure: true)
    
    // MARK: Initializers

    init(host: String, isSecure: Bool, path: String = "") {
        self.host = host
        self.isSecure = isSecure
        self.path = path
    }
    
    // MARK: Instance methods
    
    func connectionURL() -> URL {
        let scheme = isSecure ? "https" : "http"
        guard let url = URL(string: "\(scheme)://\(host)") else {
            fatalError("If you want to send a request we should provide a valid url!")
        }
        
        return url.appendingPathComponent(path)        
    }
}
