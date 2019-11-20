//
//  Repository.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain

extension LoadingState: StateMachineState {

    // MARK: Intance methods

    func canTransition(to newState: LoadingState) -> Bool {
        switch (self, newState) {
        case (.initial, .loadingContent): return true
        case (.loadingContent, .contentLoaded), (.loadingContent, .error): return true
        case (.contentLoaded, .error), (.contentLoaded, .loadingContent): return true
        case (.error, .loadingContent), (.error, .contentLoaded): return true
        default: return false
        }
    }
}

class Repository: Domain.Repository {
    private let loadingStateMachine = StateMachine<LoadingState>(state: .initial)

    var currentState: LoadingState {
        return loadingStateMachine.currentState
    }

    // MARK: Instance methods

    func beginLoading() {
        loadingStateMachine.setState(.loadingContent)
    }

    func endLoadingStateWithState(_ state: LoadingState) {
        loadingStateMachine.setState(state)
    }
}
