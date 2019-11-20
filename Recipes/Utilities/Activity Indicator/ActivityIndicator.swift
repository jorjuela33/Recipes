//
//  ActivityIndicator.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import RxCocoa
import RxSwift

enum ActivityState {
    case completed
    case initialized
    case failure
    case loading
}

class ActivityIndicator: SharedSequenceConvertibleType {
    typealias Element = ActivityState
    typealias SharingStrategy = DriverSharingStrategy

    private let lock = NSRecursiveLock()
    private let variable = BehaviorRelay(value: ActivityState.initialized)
    private let loading: SharedSequence<SharingStrategy, Element>

    // MARK: Initializers

    init() {
        loading = variable.asDriver().distinctUntilChanged()
    }

    // MARK: Instance methods

    func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Element> {
        return loading
    }

    // MARK: Private methods

    fileprivate func subscribed() {
        setState(.loading)
    }

    fileprivate func sendCompleted() {
        setState(.completed)
    }

    fileprivate func setState(_ state: ActivityState) {
        lock.lock()
        variable.accept(state)
        lock.unlock()
    }
}

extension ObservableConvertibleType {

    // MARK: ObservableConvertibleType

    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return asObservable().do(onNext: { _ in
            activityIndicator.sendCompleted()
        }, onError: { _ in
            activityIndicator.setState(.failure)
        }, onCompleted: activityIndicator.sendCompleted,
           onSubscribe: activityIndicator.subscribed
        )
    }
}

