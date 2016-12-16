//
//  ClothesTableViewController.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

// Displays clothes for the current weather and allows the user to pick their own images for the current weather.
class ClothesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentClothes = Clothing.errorGPS
    private var clothesImageHandler = ClothesImageHandler.shared
    private var selectedCellIndexPath: IndexPath? = nil
    private var imagePicker: UIImagePickerController? = nil
    private var clothes:[UIImage] = []
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewWillLayoutSubviews() {
        clothes = ClothesImageHandler.shared.getImagesFor(currentClothes)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker!.delegate = self
        imagePicker!.allowsEditing = false
        imagePicker!.sourceType = .photoLibrary
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 111
    }
    
    // MARK: - Image picker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker?.dismiss(animated: false, completion: nil)
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            if let selectedCellIndexPath = selectedCellIndexPath{
                clothesImageHandler.replaceImageFor(currentClothes, image: image, index: selectedCellIndexPath.row)
            }else{
                clothesImageHandler.addImageFor(currentClothes, image: image)
            }
            clothes = ClothesImageHandler.shared.getImagesFor(currentClothes)
        }else{
            print("Error loading image from user")
        }
        tableView.reloadData()
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clothes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesItemTableViewCell", for: indexPath) as! ClothesItemTableViewCell
        cell.clothingImage = clothes[indexPath.row]
        cell.titleLabel.text = "Steg \(indexPath.row)"
        cell.deleteCallback =  { [unowned self] in
            self.clothesImageHandler.removeImageFor(self.currentClothes, index: indexPath.row)
            self.clothes = ClothesImageHandler.shared.getImagesFor(self.currentClothes)
            self.tableView.reloadData()
        }
        
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let imagePicker = imagePicker {
            selectedCellIndexPath = indexPath
            present(imagePicker, animated: true, completion: {})
        }
    }
    
    @IBAction func addImageClicked(_ sender: UIBarButtonItem) {
        if let imagePicker = imagePicker {
            selectedCellIndexPath = nil
            present(imagePicker, animated: true, completion: {})
        }
    }
}
