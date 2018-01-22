//
//  ImageTableViewCell.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-04.
//  Copyright © 2017 Knowit. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell, UIScrollViewDelegate {

    weak var delegate: ImageTableViewCellDelegate?
    var manageMode: Bool = false {
        didSet {
            refreshConstraints()
        }
    }

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteImageButton: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        // Fix bg color on iOS 9
        backgroundColor = UIColor.clear

        photoView.isAccessibilityElement = true
        photoView.accessibilityLabel = "Egen bild. Klicka för att zooma."
        
        if constants.showDebugBorders {
            contentView.layer.borderColor = UIColor.green.cgColor
            contentView.layer.borderWidth = 1.0
            photoView.layer.borderColor = UIColor.brown.cgColor
            photoView.layer.borderWidth = 4.0
        }
    }


    // MARK: - Configure

    func configureWithClothing(clothing: Clothing, manageMode: Bool) {
        let image = clothing.image
        photoView.image = image
        photoView.isAccessibilityElement = true
        photoView.accessibilityLabel = clothing.rawValue
        self.manageMode = manageMode
    }

    func configureWithClothing(clothing: Clothing, manageMode: Bool, hideDownArrow: Bool) {
        configureWithClothing(clothing: clothing, manageMode: manageMode)
    }

    func configureWithImagePath(imagePath: String, manageMode: Bool) {
        let image = UIImage(contentsOfFile: imagePath)
        photoView.image = image
        self.manageMode = manageMode
    }


    // MARK: - Accessibility
    
    private func loadAccessibility() {
        deleteImageButton.isAccessibilityElement = true
        deleteImageButton.accessibilityLabel = "Ta bort bild"
    }
    

    // MARK: - Layout

    private func refreshConstraints() {
        photoTopConstraint.constant = manageMode ? 70 : 0
    }


    // MARK: - Actions

    @IBAction func didPressDeleteImageButton() {
        delegate?.didPressDeleteImageButton(cell: self)
    }

}


protocol ImageTableViewCellDelegate : class {
    func didPressDeleteImageButton(cell: UITableViewCell)
}
