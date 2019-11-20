//
//  ConnectionRequestValidator.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain

protocol ConnectionRequestValidator {
    static func validate(_ request: URLRequest?, response: HTTPURLResponse, data: Data?) throws
}

struct ErrorRequestValidator: ConnectionRequestValidator {
    
    // MARK: Static methods
    
    static func validate(_ request: URLRequest?, response: HTTPURLResponse, data: Data?) throws {
        guard let data = data, !data.isEmpty else { return }
        
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSONObject {
            let keyCode = jsonObject["code"] as? String ?? ""
            
            if
                /// error object
                let errorsObject = jsonObject as? [String: [String]] ?? jsonObject["errors"] as? [String: [String]],
                
                /// the first error
                let error = errorsObject.first,
                
                /// reason
                let reason = error.value.first {
                
                throw HGError(
                    key: keyCode,
                    currentValue: jsonObject,
                    reason: "\(error.key.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "base", with: "")) \(reason)"
                )
            } else if let message = jsonObject["message"] as? String {
                throw HGError(key: keyCode, currentValue: jsonObject, reason: message)
            }
        }
    }
}
