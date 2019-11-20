//
//  HGError.swift
//  Domain
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

public struct HGError: Error {
    public let key: String
    public let currentValue: Any?
    public let reason: String?
    public let file: StaticString?
    public let function: StaticString?
    public let line: UInt

    // MARK: Initializers

    public init(
        key: String,
        currentValue: Any? = nil,
        reason: String? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
        ) {

        self.key = key
        self.currentValue = currentValue
        self.reason = reason
        self.file = file
        self.function = function
        self.line = line
    }
}

extension HGError: CustomStringConvertible {

    // MARK: CustomStringConvertible

    public var description: String {
        let location = ((String(describing: file).components(separatedBy: "/").last ?? "").components(separatedBy: ".").first ?? "")
        let info: [(String, Any?)] = [("- reason", reason), ("- location", location), ("- key", key), ("- currentValue", currentValue)]
        let infoString = info.map({ "\($0.0): \($0.1 ?? "nil")" }).joined(separator: "\n")
        return "Error. \n\(infoString)"
    }
}

extension HGError: LocalizedError {

    // MARK: LocalizedError

    public var errorDescription: String? {
        return reason
    }

    public var localizedDescription: String {
        return reason ?? ""
    }
}

