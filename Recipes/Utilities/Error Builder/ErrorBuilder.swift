//
//  ErrorBuilder.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

let defaultErrorTitle = "Error"
let defaultErrorMessage = "We have issues at this moment. Please try again later."

struct ErrorBuilder {

    // MARK: Static methods

    static func create(_ error: Error) -> Message {
        return Message(title: defaultErrorTitle, message: error.localizedDescription)
    }
}
