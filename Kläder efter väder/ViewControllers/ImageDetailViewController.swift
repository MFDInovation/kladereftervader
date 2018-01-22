//
//  ImageDetailViewController.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-10.
//  Copyright © 2017 Knowit. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { get { return .all } }
    override var shouldAutorotate: Bool { get { return false } }

    @IBOutlet weak var imageScrollView: ImageScrollView!

    var image: UIImage? = nil
    var startZoomScale: CGFloat = 0
    let startOrientation = UIApplication.shared.statusBarOrientation


    override func viewDidLoad() {
        super.viewDidLoad()

        // Lock to current orientation
        UIDevice.current.setValue(startOrientation.rawValue, forKey: "orientation")

        if imageScrollView != nil {
            imageScrollView.display(image: image!)
            imageScrollView.contentSize = view.intrinsicContentSize
            startZoomScale = imageScrollView.zoomScale
            imageScrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }

    deinit {
        imageScrollView.removeObserver(self, forKeyPath: "contentOffset")
    }


    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.zoomView?.contentMode = .scaleAspectFit
        imageScrollView.zoomView?.frame = imageScrollView.bounds
        imageScrollView.adjustFrameToCenter()
    }


    // MARK: - Key-Value Observing

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if imageScrollView.zoomScale < startZoomScale {
                // Before dismissing, make sure the presenting view controller hasn't rotated
                UIDevice.current.setValue(startOrientation.rawValue, forKey: "orientation")
                dismiss(animated: true, completion: nil)
            }
        }
    }

}
