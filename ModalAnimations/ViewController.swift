//
//  ViewController.swift
//  ModalAnimations
//
//  Created by Vasco Pinto on 09/04/2018.
//  Copyright © 2018 Vasco Pinto. All rights reserved.
//

import UIKit

struct Item {
    let title: String
    let texts: [String]
}

extension Item: CustomDebugStringConvertible {

    var debugDescription: String {
        return title
    }
}

typealias ModuleViewController = Expandable & UIViewController

protocol Expandable {
    func expanded(_ expanded: Bool)
}

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var items: [Item] = []
    var viewControllers: [ModuleViewController] = []
    let layout = UICollectionViewFlowLayout()
    private var selected: IndexPath?

    init() {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {

        items = (0..<20).map {
            Item(title: "Item \($0)", texts: [])
        }

        viewControllers = items.map(ModalViewController.init)

        viewControllers.forEach {
            addChildViewController($0)
            $0.didMove(toParentViewController: self)
            $0.transitioningDelegate = self
            $0.view.backgroundColor = UIColor.randomColor()
        }

        collectionView?.register(ModuleCell.self, forCellWithReuseIdentifier: ModuleCell.reuseIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.darkGray

        layout.minimumLineSpacing = 1
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModuleCell.reuseIdentifier, for: indexPath) as! ModuleCell

        let viewController = viewControllers[indexPath.row]
        cell.hostedView = viewController.view
        viewController.expanded(false)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: 100)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? ModuleCell else { return }

        selected = indexPath

        let viewController = viewControllers[indexPath.row]

        viewController.willMove(toParentViewController: nil)
        viewController.removeFromParentViewController()

        if let modal = viewController as? ModalViewController {
            modal.dismissCompletion = dismissCompletion(for: modal, cell: cell)
        }

        present(viewController, animated: true)
    }

    private func dismissCompletion(for viewController: UIViewController, cell: ModuleCell) -> (() -> Void)? {
        return { [weak self] in
            self?.addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
            cell.hostedView = viewController.view
        }
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard
            let indexPath = collectionView?.indexPathsForSelectedItems?.first,
            let cell = collectionView?.cellForItem(at: indexPath)
        else { return nil }

        let frame = view.convert(cell.bounds, from: cell)

        return ModulePresentAnimatedTransitioning(originalFrame: frame)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard
            let indexPath = selected,
            let cell = collectionView?.cellForItem(at: indexPath) as? ModuleCell,
            let modal = dismissed as? ModalViewController
        else { return nil }

        let frame = view.convert(cell.bounds, from: cell)

        let completion = dismissCompletion(for: dismissed, cell: cell)
        let transitioning = ModuleDismissAnimatedTransitioning(destinationFrame: frame, cell: cell, interactionController: modal.interactionController)
        transitioning.completion = completion

        return transitioning
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        guard
            let animator = animator as? ModuleDismissAnimatedTransitioning,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
        else { return nil }

        return interactionController
    }
}
