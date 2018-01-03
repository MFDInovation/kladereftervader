//
//  ImagesViewController.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-04.
//  Copyright © 2017 Knowit. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var manageImagesButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var navigationButtonsStackView: UIStackView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    var manageMode: Bool = false
    var weather: Weather? {
        didSet {
            if !manageMode {
                data = []
                loadData()
            }
        }
    }

    private var viewDidLayoutSubviewsForTheFirstTime = true

    private var data: Array<ClothesData> = []
    private var currentIndex: Int = 0 {
        didSet {
            updateNavigationButtons()
        }
    }

    private let imageToBottomSpacing : CGFloat = 100

    // 'Manage Images' UI
    private let headerHeight : CGFloat = 60
    private let headerPadding : CGFloat = 16

    // Custom transition (for zoom view controller)
    let transition = Animator()
    var selectedCell: ImageTableViewCell?


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = manageMode ? UIColor.white : UIColor.clear
        pageControl.numberOfPages = 0
        setupButtons()
        updateNavigationButtons()
        loadAccessibility()
        if manageMode {
            loadData()
        }

        if constants.showDebugBorders {
            collectionView.layer.borderColor = UIColor.red.cgColor
            collectionView.layer.borderWidth = 1.0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !manageMode {return}

        // Make sure this is the first time, else return
        guard viewDidLayoutSubviewsForTheFirstTime == true else {return}

        jumpToCurrentWeather()
        viewDidLayoutSubviewsForTheFirstTime = false
    }


    // MARK: - Data

    private func loadData() {

        if manageMode {
            // Get all clothes and all images
            for clothing in Clothing.allValues {
                let imagePaths = ClothesImageHandler.shared.getImagePathsFor(clothing)
                let clothingData = ClothesData(clothing: clothing, imagePaths: imagePaths)
                data.append(clothingData)
            }
        } else if weather != nil {
            let clothes = Clothing.create(from: weather!)
            let imagePaths = ClothesImageHandler.shared.getImagePathsFor(clothes)
            let clothesData = ClothesData(clothing: clothes, imagePaths: imagePaths)
            data.append(clothesData)
        }

        collectionView?.reloadData()
        setupPageControl()
        updateNavigationButtons()
    }


    // MARK: - UI Setup

    private func setupButtons() {

        // Adjust button sizes for smallen screen sizes
        if UIDevice.isScreen35inch() || UIDevice.isScreen4inch() {
            menuStackView.spacing = 4.0
            navigationButtonsStackView.spacing = 4.0
            let buttons: Array<UIButton> = [manageImagesButton, doneButton, addButton, helpButton, leftButton, rightButton]
            for btn in buttons {
                if (btn == manageImagesButton) {
                    btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 9, bottom: 12, right: 9)
                } else {
                    btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
                }
                
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
            }
        }

        // Hide buttons based on manageMode
        manageImagesButton.isHidden = manageMode
        doneButton.isHidden = !manageMode
        addButton.isHidden = !manageMode
    }

    private func updateNavigationButtons() {

        // Update navigation buttons
        let leftEnabled = canScrollLeft()
        leftButton.isEnabled = leftEnabled
        leftButton.alpha = leftEnabled ? 1.0 : 0.6

        let rightEnabled = canScrollRight()
        rightButton.isEnabled = rightEnabled
        rightButton.alpha = rightEnabled ? 1.0 : 0.6

        leftButton.accessibilityLabel = "Bläddra till vänster. \(leftEnabled ? "Aktiverad" : "Inaktiverad")"
        
        rightButton.accessibilityLabel = "Bläddra till höger. \(rightEnabled ? "Aktiverad" : "Inaktiverad")"
        
        // Update Page Control
        pageControl.currentPage = currentIndex
    }

    private func setupPageControl() {
        if collectionView.numberOfSections == 1 {
            pageControl.numberOfPages = collectionView.numberOfItems(inSection: 0)
        }
    }

    
    // MARK: - Show errors
    
    func showNetworkError() {
        showError(errorClothing: Clothing.errorNetwork)
    }
    
    func showGPSError() {
        showError(errorClothing: Clothing.errorGPS)
    }
    
    private func showError(errorClothing: Clothing) {
        let clothesData = ClothesData(clothing: errorClothing)
        data.append(clothesData)
        collectionView.reloadData()
    }


    // MARK: - Navigation

    // Open a new instance of ImagesViewController in 'manage mode'.
    @IBAction private func manageImages() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ImagesVC") as! ImagesViewController
        controller.manageMode = true
        controller.weather = weather
        present(controller, animated: true, completion: nil)
    }

    // Close 'Manage Images'
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func showHelp() {
        let title = manageMode ? "Lägga till egna bilder" : "Kläder efter väder"
        let message = manageMode ? constants.changeClothesHelpText : constants.startHelptText

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let subview = alert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.alpha = 1
        alertContentView.backgroundColor = UIColor.white
        alertContentView.layer.cornerRadius = 10
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.isAccessibilityElement = true
        alert.accessibilityLabel = message
        present(alert, animated: true, completion: nil)
    }

    func showZoomViewControllerForCell(cell: ImageTableViewCell) {
        selectedCell = cell
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetail") as! ImageDetailViewController
        detailVC.image = cell.photoView.image
        detailVC.transitioningDelegate = self
        present(detailVC, animated: true, completion: nil)
    }


    // MARK: - Add/replace image

    // User adds a new image to the app
    @IBAction private func addImage() {
        let cell = visibleCell()
        cell?.pickImage()
    }


    // MARK: - Visible cell

    // Only one cell should be on screen at once, so we can do the following.

    private func visibleCellIndexPath() -> IndexPath {
        // Find the center point for the current image withing the collection view
        let centerX = collectionView.contentOffset.x + collectionView.frame.width/2
        // Translate point to an index path
        return collectionView.indexPathForItem(at: CGPoint(x: centerX, y: collectionView.center.y))!
    }

    private func visibleCellIndex() -> Int {
        let indexPath = visibleCellIndexPath()
        return (indexPath.row)
    }

    private func visibleCell() -> ImagesCollectionViewCell? {
        let indexPath = visibleCellIndexPath()
        let cell = collectionView?.cellForItem(at: indexPath) as! ImagesCollectionViewCell
        return cell
    }


    // MARK: - Scrolling

    private func scrollToIndex(index: Int, animated: Bool) {
        collectionView?.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

    private func scrollToCurrentIndex(animated: Bool) {
        scrollToIndex(index: currentIndex, animated: animated)
    }

    private func jumpToCurrentWeather() {

        if !manageMode {return}

        // In manage mode, show cell for current weather
        if let currentWeather = weather {
            let clothingForCurrentWeather = Clothing.create(from: currentWeather)
            let indexForCurrentWeather = Clothing.allValues .index(of: clothingForCurrentWeather)
            currentIndex = indexForCurrentWeather!
            scrollToCurrentIndex(animated: false)
        }
    }

    @IBAction func scrollRight() {
        if canScrollRight() {
            currentIndex += 1
            scrollToCurrentIndex(animated: true)
        }
    }

    @IBAction func scrollLeft() {
        if canScrollLeft() {
            currentIndex -= 1
            scrollToCurrentIndex(animated: true)
        }
    }

    private func canScrollLeft() -> Bool {
        return currentIndex != 0
    }

    private func canScrollRight() -> Bool {
        if collectionView.numberOfSections != 1 {
            return false
        }
        return (currentIndex + 1 < collectionView.numberOfItems(inSection: 0))
    }


    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if data.count == 0 {
            return 0
        }

        if manageMode {
            return data.count
        }

        let clothesData = data.first

        // Number of user images +1 for the Clothing illustration
        return clothesData!.imagePaths.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagesCollectionViewCell

        if manageMode {
            cell.configureWithClothesData(data: data[indexPath.row])
        } else {
            let isLast = isLastItem(indexPath: indexPath)
            let clothesData = data.first
            // The last cell should contain the current weatcher clothes illustration
            if isLast {
                cell.configureWithClothing(clothing: (clothesData?.clothing)!)
            } else {
                cell.configureWithImagePath(imagePath: (clothesData?.imagePaths[indexPath.row])!)
            }
        }

        return cell
    }


    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height -= 4
        return size
    }

    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if manageMode {
            // Make sure we start at top image every time the cell is displayed
            let myCell = cell as! ImagesCollectionViewCell
            myCell.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            myCell.updateDownArrow()
        }
    }


    // MARK: - UIScrollViewDelegate

    // When scrolling with pan gesture ends
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = visibleCellIndex()
    }


    // MARK: - Helpers

    private func isLastItem(indexPath: IndexPath) -> Bool {
        return (indexPath.item == collectionView.numberOfItems(inSection: indexPath.section)-1)
    }

    // MARK: - Accessibility
    
    func loadAccessibility(){
        if #available(iOS 10.0, *) {
            doneButton.isAccessibilityElement = true
            doneButton.accessibilityLabel = "Avsluta till huvudskärm"
            
            addButton.isAccessibilityElement = true
            addButton.accessibilityLabel = "Lägg till bild för nuvarande väder"
            
            helpButton.isAccessibilityElement = true
            helpButton.accessibilityLabel = "Hjälpruta med instruktioner"
            
            pageControl.isAccessibilityElement = true
            pageControl.accessibilityLabel = "Bilder att bläddra mellan"
            
            leftButton.isAccessibilityElement = true
            rightButton.isAccessibilityElement = true
        } else {
            // Fallback on earlier versions
        }
    }
}

extension ImagesViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.photoView = selectedCell?.photoView
        transition.presenting = true
        
        transition.dismissCompletion = {
            self.selectedCell?.photoView.isHidden = false
        }
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}


struct ClothesData {
    var clothing: Clothing?
    var imagePaths: Array<String> = []

    init(clothing: Clothing) {
        self.clothing = clothing
    }
    init(clothing: Clothing, imagePaths: Array<String>) {
        self.clothing = clothing
        self.imagePaths = imagePaths
    }
}
