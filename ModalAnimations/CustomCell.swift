//
//  CustomCell.swift
//  ModalAnimations
//
//  Created by Vasco Pinto on 09/04/2018.
//  Copyright © 2018 Vasco Pinto. All rights reserved.
//

import UIKit

public extension UICollectionViewCell {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol ModuleCellProtocol: class {
    var hostedView: UIView? { get set }
}

public final class ModuleCell: UICollectionViewCell, ModuleCellProtocol {

    public var hostedView: UIView? {
        didSet {
            guard let hostedView = hostedView else { return }

            hostedView.frame = contentView.bounds
            contentView.addSubview(hostedView)
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        guard hostedView?.superview == contentView else { return }

        hostedView?.removeFromSuperview()
        hostedView = nil
    }
}
