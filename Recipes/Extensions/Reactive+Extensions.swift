//
//  Observable+Transformations.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift

extension ObservableType where Element == Bool {
    func not() -> Observable<Bool> {
        return self.map(!)
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }

    func catchErrorJustComplete() -> RxSwift.Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func mapToVoid() -> RxSwift.Observable<Void> {
        return map { _ in }
    }
}

extension Reactive where Base: UIViewController {
    var message: Binder<Message> {
        return Binder(self.base) { viewController, message in
            let alertController = UIAlertController(title: message.title, message: message.message, preferredStyle: message.preferedStyle)
            message.actions.forEach(alertController.addAction)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}

extension Reactive where Base: LoadingIndicator {
     var state: Binder<ActivityState> {
           return Binder(self.base) { loadingIndicator, state in
               guard state == .loading else {
                   loadingIndicator.hide(animated: true)
                   return
               }

               loadingIndicator.show(animated: true)
           }
       }
 }
