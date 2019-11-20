//
//  LoadingIndicator.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import MBProgressHUD

class LoadingIndicator: MBProgressHUD {

    var loadingMessage: String? {
        get {
            return label.text
        }

        set {
            label.text = newValue
        }
    }

    // MARK: Class methods

    class func show(in view: UIView, loadingMessage: String = "Loading....") -> LoadingIndicator {
        let loadingIndicator = LoadingIndicator.showAdded(to: view, animated: false)
        loadingIndicator.removeFromSuperViewOnHide = false
        loadingIndicator.hide(animated: false)
        loadingIndicator.label.text = loadingMessage
        loadingIndicator.contentColor = .white
        loadingIndicator.bezelView.color = UIColor.black.withAlphaComponent(0.75)
        loadingIndicator.bezelView.style = .solidColor
        return loadingIndicator
    }
}
