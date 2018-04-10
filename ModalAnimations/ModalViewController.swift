//
//  ModalViewController.swift
//  ModalAnimations
//
//  Created by Vasco Pinto on 09/04/2018.
//  Copyright © 2018 Vasco Pinto. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController, Expandable {

    var dismissCompletion: (() -> Void)?
    let item: Item

    private let dot = UIView()
    private let dotSize: CGFloat = 50
    let dismissButton = UIButton(type: .custom)

    private(set) var interactionController: ModuleSwipeInteractiveTransition?

    init(item: Item) {
        self.item = item

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("view will appear: \(item)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("view will disap: \(item)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        interactionController = ModuleSwipeInteractiveTransition(viewController: self)

        dismissButton.setTitle("Dismiss \(item.title)", for: .normal)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        view.addSubview(dismissButton)

        dot.frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
        dot.layer.cornerRadius = dotSize / 2
        dot.backgroundColor = UIColor.white
        view.addSubview(dot)

        let leftBar = UIView()
        leftBar.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftBar)
        view.sendSubview(toBack: leftBar)

        NSLayoutConstraint.activate([

            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),

            leftBar.topAnchor.constraint(equalTo: view.topAnchor),
            leftBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftBar.widthAnchor.constraint(equalToConstant: 30),
            leftBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)

            ])
    }

    @objc func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.dismissCompletion?()
        }
    }

    func expanded(_ expanded: Bool) {

        dismissButton.alpha = expanded ? 1 : 0
        dot.center = dotCenter(for: expanded)
    }

    func dotCenter(for expanded: Bool) -> CGPoint {

        if expanded == false {
            return CGPoint(x: view.bounds.midX, y: dotSize)
        } else {
            return CGPoint(x: view.bounds.minX + dotSize, y: view.bounds.maxY - dotSize)
        }
    }
}
