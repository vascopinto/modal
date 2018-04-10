//
//  Helpers.swift
//  ModalAnimations
//
//  Created by Vasco Pinto on 09/04/2018.
//  Copyright © 2018 Vasco Pinto. All rights reserved.
//

import UIKit

public extension UIColor {
    class func randomColor() -> UIColor {
        let red = CGFloat(Number.random(from: 0, to: 255)) / 255.0
        let green = CGFloat(Number.random(from: 0, to: 255)) / 255.0
        let blue = CGFloat(Number.random(from: 0, to: 255)) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

public struct Number {
    static func random(from: Int, to: Int) -> Int {
        guard from < to else { fatalError("`from` MUST be less than `to`") }
        let delta = UInt32(to + 1 - from)

        return from + Int(arc4random_uniform(delta))
    }
}

