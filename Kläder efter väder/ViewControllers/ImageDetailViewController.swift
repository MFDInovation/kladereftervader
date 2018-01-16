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
    var startZoomScale: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        if imageScrollView != nil {
            imageScrollView.display(image: image!)
            imageScrollView.contentSize = view.intrinsicContentSize
            startZoomScale = imageScrollView.zoomScale
            imageScrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.zoomView?.contentMode = .scaleAspectFit
        imageScrollView.zoomView?.frame = imageScrollView.bounds
        imageScrollView.adjustFrameToCenter()
    }

    deinit {
        imageScrollView.removeObserver(self, forKeyPath: "contentOffset")
    }


    // MARK: - Actions

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Key-Value Observing

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if imageScrollView.zoomScale < startZoomScale {
                dismiss(animated: true, completion: nil)
            }
        }
    }

}
