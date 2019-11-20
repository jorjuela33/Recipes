//
//  Storyboard+Initialization.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import UIKit

extension UIStoryboard {

    enum StoryboardName: String {
        case main = "Main"
    }

    // MARK: Initializers

    convenience init(storyboardName: StoryboardName, bundle: Bundle? = nil) {
        self.init(name: storyboardName.rawValue, bundle: bundle)
    }

    // MARK: Instance methods

    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("No view controller found")
        }

        return viewController
    }
}
