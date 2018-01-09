//
//  ImagesCollectionViewCell.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-04.
//  Copyright © 2017 Knowit. All rights reserved.
//

import UIKit

class ImagesCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate, ImageTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var arrowDownImageView: UIImageView!
    @IBOutlet weak private var gradientView : UIView!

    var manageMode: Bool = false {
        didSet {
            setupGradient()
        }
    }

    private var data: ClothesData?
    private var clothing: Clothing?
    private var imagePath: String?

    private var currentIndex: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        // Title label shadow
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowRadius = 2.0
        titleLabel.layer.shadowOpacity = 1

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = clothing?.rawValue
        
        arrowDownImageView.isAccessibilityElement = true
        arrowDownImageView.accessibilityLabel = "Det finns inlagda bilder"
        
        if constants.showDebugBorders {
            contentView.layer.borderColor = UIColor.blue.cgColor
            contentView.layer.borderWidth = 4.0
        }
    }


    // MARK: - Layout

    func updateDownArrow() {
        if let indexPath = tableView.indexPathsForVisibleRows?.last {
            let lastItem = ((indexPath.row)+1 == tableView.numberOfRows(inSection: 0))
            arrowDownImageView.isHidden = lastItem
        }
    }

    // Gradient view (bottom fade)
    private func setupGradient() {
        if !manageMode {
            gradientView.isHidden = true
        } else {
            gradientView.isHidden = false
            let gradientColor = UIColor.white
            gradientView.backgroundColor = gradientColor;
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = gradientView.bounds
            gradientLayer.colors = [UIColor.clear.cgColor, gradientColor.cgColor]
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.8)
            gradientView.layer.mask = gradientLayer
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.rowHeight = contentView.frame.size.height
    }


    // MARK: - Configure

    func configureWithClothesData(data: ClothesData) {
        cleanup()
        self.data = data
        titleLabel.isHidden = false
        manageMode = true
        tableView.isScrollEnabled = data.imagePaths.count > 0
        titleLabel.text = constants.getClothingName(data.clothing)
        tableView.reloadData()
        if manageMode {
            updateDownArrow()
        }
    }

    func configureWithClothing(clothing: Clothing) {
        cleanup()
        self.clothing = clothing
        tableView.reloadData()
        if manageMode {
            updateDownArrow()
        }
    }

    func configureWithImagePath(imagePath: String) {
        cleanup()
        self.imagePath = imagePath
        tableView.reloadData()
        if manageMode {
            updateDownArrow()
        }
    }

    private func cleanup() {
        manageMode = false
        data = nil
        clothing = nil
        imagePath = nil
        titleLabel.isHidden = true
        titleLabel.text = ""
        tableView.isScrollEnabled = false
    }


    // MARK: - Add image

    func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = .currentContext
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            picker.delegate = self
            let parentVC = parentViewController()
            parentVC?.present(picker, animated: true, completion: nil)
        } else {
            print("Can't access photo library")
            // TODO: Show error to user?
        }
    }

    // UIImagePickerControllerDelegate
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.dismiss(animated: true, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ClothesImageHandler.shared.addImageFor((data?.clothing)!, image: image)
            let imagePath = ClothesImageHandler.shared.getImagePathsFor((data?.clothing)!).last
            data?.imagePaths.append(imagePath!)
            let newIndexPath = IndexPath(row: (data?.imagePaths.count)!, section: 0)
            if !tableView.isScrollEnabled {
                tableView.isScrollEnabled = true
            }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.scrollToRow(at: newIndexPath, at: .top, animated: true)
        }
    }

    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }


    // MARK: - Visible cell

    private func visibleCellIndexPath() -> IndexPath {
        // Find the center point (y) for the current image within the table view
        let centerY = tableView.contentOffset.y + tableView.frame.height/2
        // Translate point to an index path
        return tableView.indexPathForRow(at: CGPoint(x: tableView.center.x, y: centerY))!
    }

    private func visibleCellIndex() -> Int {
        let indexPath = visibleCellIndexPath()
        return indexPath.row
    }

    private func visibleCell() -> UITableViewCell? {
        let indexPath = visibleCellIndexPath()
        let cell = tableView.cellForRow(at: indexPath)
        return cell
    }


    // MARK: - Scrolling

    func scrollToCurrentIndex(animated: Bool) {
        tableView.scrollToRow(at: IndexPath.init(row: currentIndex, section: 0), at: .top, animated: animated)
    }


    // MARK: - Table view data source

    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data != nil {
            return 1 + data!.imagePaths.count
        }
        return 1
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseIdentifier = (manageMode && indexPath.row > 0) ? "EditableImageCell" : "ImageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ImageTableViewCell

        if manageMode {
            if indexPath.row == 0 { // first row
                let hideDownArrow = (data?.imagePaths.count == 0)
                cell.configureWithClothing(clothing: (data?.clothing)!, manageMode: manageMode, hideDownArrow: hideDownArrow)
            } else {
                cell.configureWithImagePath(imagePath: (data?.imagePaths[indexPath.row-1])!, manageMode: manageMode)
                cell.delegate = self
            }
        } else {
            if clothing != nil {
                cell.configureWithClothing(clothing: clothing!, manageMode: manageMode)
            } else if imagePath != nil {
                cell.configureWithImagePath(imagePath: imagePath!, manageMode: manageMode)
            }
        }
        return cell
    }


    // MARK: - UITableViewDelegate

    internal func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Error images should not be selectable (zoomable)
        if clothing == Clothing.errorGPS || clothing == Clothing.errorNetwork {
            return nil
        }
        return indexPath
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ImageTableViewCell
        let imagesVC = parentViewController() as! ImagesViewController
        imagesVC.showZoomViewControllerForCell(cell: cell)
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
    }


    // MARK: - ImageTableViewCellDelegate

    internal func didPressDeleteImageButton(cell: UITableViewCell) {
        // Ask user if image should be deleted
        let alert = UIAlertController(title: "Vill du ta bort bilden?", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Ta bort", style: .default, handler: { action in
            let indexPath = self.tableView.indexPath(for: cell)
            // Remove image, both from main store and from cell data
            ClothesImageHandler.shared.removeImageFor((self.data?.clothing)!, index: (indexPath?.row)!-1)
            self.data?.imagePaths.remove(at: (indexPath?.row)!-1)
            // Remove cell
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        })
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let vc = parentViewController()
        vc?.present(alert, animated: true, completion: nil)
    }


    // MARK: - UIScrollViewDelegate

    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = visibleCellIndex()
        updateDownArrow()
    }


    // MARK: - Helpers

    private func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
