//
//  ClothesItemTableViewCell.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

class ClothesItemTableViewCell: UITableViewCell {
    var clothingImage: UIImage? {
        set {
            clothingImageView.image = newValue
            if let newValue = newValue {
                let aspectRatio = CGFloat(newValue.size.width) / CGFloat(newValue.size.height)
                aspectRatioConstraint = aspectRatioConstraint.setMultiplier(multiplier: aspectRatio)
            }
        }
        get {
            return clothingImageView.image
        }
    }
    public var deleteCallback: (() -> ())?
    @IBOutlet private weak var clothingImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    @IBAction func didPressDelete(_ sender: Any) {
        deleteCallback?()
    }
}
