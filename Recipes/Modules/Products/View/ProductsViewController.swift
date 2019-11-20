//
//  ProductsViewController.swift
//  Recipes
//
//  Created by Jorge Orjuela on 11/20/19.
//  Copyright © 2019 Jorge Orjuela. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ProductsViewController: ViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var orderButton: UIButton!

    private let disposeBag = DisposeBag()

    var presenter: ProductsPresenter?
    var swipeStateMachine: SwipeToEditStateMachine!

    override func viewDidLoad() {
        super.viewDidLoad()
        swipeStateMachine = SwipeToEditStateMachine(collectionView: collectionView)
        bindPresenter()
    }

    // MARK: Private methods

    private func bindPresenter() {
        let aspectRatio: CGFloat = 97 / 75
        let order = orderButton.rx.tap.asDriver()
        let refreshControl = UIRefreshControl()
        let pullDownToRefresh = refreshControl.rx.controlEvent(.valueChanged).asDriver()
        let widthProportion: CGFloat = 0.4
        let width = UIScreen.main.bounds.width * widthProportion
        let input = ProductsPresenter.Input(order: order, pullDownToRefresh: pullDownToRefresh)
        let output = presenter?.transform(input)

        collectionView.dataSource = output?.datasource
        collectionView.refreshControl = refreshControl

        output?.datasource.delegate = self
        output?.datasource.defaultMetrics.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        output?.datasource.registerReusableViewsWithCollectionView(collectionView)
        output?.datasource.defaultMetrics.columnSpacing = 20
        output?.datasource.defaultMetrics.rowSize = CGSize(width: width, height: width * aspectRatio)
        output?.datasource.defaultMetrics.rowSpacing = 20
        output?.datasource.defaultMetrics.separatorColor = .clear

        output?.error.drive(rx.message).disposed(by: disposeBag)
        output?.orderHidden.drive(orderButton.rx.isHidden).disposed(by: disposeBag)
        output?.orderTitle.drive(onNext: { [weak self] title in
            self?.orderButton.setTitle(title, for: .normal)
        })
        .disposed(by: disposeBag)
    }
}

extension ProductsViewController: CollectionViewDelegate {}
