//
//  imagePageViewController.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-11-15.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

class ImagePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var images = [#imageLiteral(resourceName: "gps_error")]
    //private var currentIndex = 0
    
    func viewControllerForIndex(_ index: Int) -> UIViewController {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
        viewController.image = images[safe: index]
        viewController.pageIndex = index
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        setViewControllers([viewControllerForIndex(0)], direction: .forward, animated: true, completion: {_ in })
    }
    
    func setImages(_ images: [UIImage], animated: Bool = true) {
        self.images = images
        setViewControllers([viewControllerForIndex(0)], direction: .forward, animated: animated, completion: {_ in })
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = ((viewController as! ImageViewController).pageIndex + 1) //% images.count
        if index >= images.count{ return nil }
        print(index)
        return viewControllerForIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = ((viewController as! ImageViewController).pageIndex - 1) //% images.count
        if index < 0 { return nil}
        return viewControllerForIndex(index)
    }
    

}
