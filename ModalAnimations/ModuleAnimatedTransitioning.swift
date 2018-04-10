//
//  ModuleAnimatedTransitioning.swift
//  ModalAnimations
//
//  Created by Vasco Pinto on 10/04/2018.
//  Copyright © 2018 Vasco Pinto. All rights reserved.
//

import UIKit

final class ModulePresentAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval = 1.4
    private let originalFrame: CGRect

    init(originalFrame: CGRect) {
        self.originalFrame = originalFrame

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let to = transitionContext.viewController(forKey: .to) as? ModalViewController
        else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: to)

        containerView.addSubview(to.view)
        to.view.frame = originalFrame

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                to.view.frame = finalFrame
                to.expanded(true)
            },
            completion: { _ in
                to.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

final class ModuleDismissAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval = 1.4
    let interactionController: ModuleSwipeInteractiveTransition?

    private let cell: ModuleCellProtocol
    private let destinationFrame: CGRect
    var completion: (() -> Void)?

    init(destinationFrame: CGRect, cell: ModuleCellProtocol, interactionController: ModuleSwipeInteractiveTransition?) {
        self.destinationFrame = destinationFrame
        self.cell = cell
        self.interactionController = interactionController

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let from = transitionContext.viewController(forKey: .from) as? ModalViewController,
            let to = transitionContext.viewController(forKey: .to)
        else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(to.view)
        containerView.addSubview(from.view)

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                from.view.frame = self.destinationFrame
                from.expanded(false)
                from.view.layoutIfNeeded()
            },
            completion: { _ in
                from.view.setNeedsUpdateConstraints()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

    func animationEnded(_ transitionCompleted: Bool) {

        if transitionCompleted {
            completion?()
        }
    }
}

final class ModuleSwipeInteractiveTransition: UIPercentDrivenInteractiveTransition {

    private(set) var interactionInProgress = false
    private var shouldCompleteTransition = false

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        super.init()

        self.viewController = viewController

        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = .left
        viewController.view.addGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {

        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        var progress = (translation.x / (viewController!.view.bounds.width / 3))
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))

//        print("Progress: \(progress)")

        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController?.dismiss(animated: true)
        case .changed:
            shouldCompleteTransition = progress > 0.25
            update(progress)
        case .ended, .cancelled:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
            viewController?.view.layoutIfNeeded()
        case .failed:
            cancel()
            interactionInProgress = false
        default:
            break
        }
    }
}

