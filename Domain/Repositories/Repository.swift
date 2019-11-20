//
//  Repository.swift
//  Domain
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Foundation

public enum LoadingState {
    case contentLoaded
    case error
    case initial
    case loadingContent
}

public protocol Repository {
    var currentState: LoadingState { get }
}
