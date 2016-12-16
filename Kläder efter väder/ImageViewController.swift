//
//  imageViewController.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-11-15.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit
// Stores and displays one image in the pageview
class ImageViewController: UIViewController {
    //This vie could be created a little late. These functions are to make sure that then image is set as soon as possible.
    var image:UIImage? = nil{
        didSet{
            imageView?.image = image
        }
    }
    var pageIndex: Int = 0
    
    @IBOutlet private weak var imageView: UIImageView!{
        didSet{
            imageView.image = image
        }
    }
}
