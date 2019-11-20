//
//  OrderViewController.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class OrderViewController: ViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var newOrderButton: UIButton!

    private let disposeBag = DisposeBag()

    var presenter: OrderPresenter?
    var swipeStateMachine: SwipeToEditStateMachine!

    override func viewDidLoad() {
        super.viewDidLoad()
        swipeStateMachine = SwipeToEditStateMachine(collectionView: collectionView)
        bindPresenter()
    }

    // MARK: Private methods

    private func bindPresenter() {
        let newOrder = newOrderButton.rx.tap.asDriver()
        let widthProportion: CGFloat = 0.846
        let input = OrderPresenter.Input(newOrder: newOrder)
        let output = presenter?.transform(input)

        collectionView.dataSource = output?.datasource

        output?.datasource.delegate = self
        output?.datasource.registerReusableViewsWithCollectionView(collectionView)
        output?.datasource.defaultMetrics.rowSize = CGSize(width: UIScreen.main.bounds.width * widthProportion, height: 56)
    }
}

extension OrderViewController: CollectionViewDelegate {}
