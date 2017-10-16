//
//  ImageDetailViewController.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-10.
//  Copyright © 2017 Knowit. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var imageScrollView: ImageScrollView!

    var image: UIImage? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        if imageScrollView != nil {
            imageScrollView.display(image: image!)
        }
    }

    override func viewDidLayoutSubviews() {
        imageScrollView.zoomView?.contentMode = .scaleAspectFit
        imageScrollView.zoomView?.frame = imageScrollView.bounds
        imageScrollView.adjustFrameToCenter()
    }


    // MARK: - Actions

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }

}
