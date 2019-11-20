//
//  Observable+Transformations.swift
//  Application
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import RxSwift

extension Observable where Element: Sequence, Element.Iterator.Element: DomainTypeConvertible {
    typealias DomainType = Element.Iterator.Element.DomainType

    func mapToDomain() -> Observable<[DomainType]> {
        return map { sequence -> [DomainType] in
            return sequence.mapToDomain()
        }
    }
}

extension Sequence where Iterator.Element: DomainTypeConvertible {
    typealias Element = Iterator.Element

    func mapToDomain() -> [Element.DomainType] {
        return map {
            return $0.asDomain()
        }
    }
}
