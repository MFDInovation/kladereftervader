//
//  imageViewController.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-11-15.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

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
