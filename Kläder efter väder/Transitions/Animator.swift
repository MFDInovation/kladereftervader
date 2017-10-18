//
//  Animator.swift
//  Kläder efter väder
//
//  Created by Claes Jacobsson on 2017-10-17.
//  Copyright © 2017 Knowit. All rights reserved.
//

import Foundation
import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.3
    var presenting = true
    var photoView: UIImageView? = nil {
        didSet {
            imageFrame = (photoView?.convert((photoView?.bounds)!, to: nil))!
            image = photoView?.image
        }
    }
    
    private var imageFrame = CGRect.zero
    private var image: UIImage? = nil
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let fromView = fromVC?.view
        let toView = toVC?.view
        
        // Initial and final frame of image animation
        let initialFrame = presenting ? imageFrame : toView?.frame
        let finalFrame = presenting ? toView?.frame : imageFrame
        
        // Create an image view to show image during transition
        let imageView = UIImageView(frame: initialFrame!)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        // Hide toView initially
        toView?.alpha = 0.0
        
        // Hide detail image scroll view during transition
        let detailVC = presenting ? toVC as! ImageDetailViewController : fromVC as! ImageDetailViewController
        detailVC.imageScrollView.isHidden = true
        
        // Prepare containerView
        containerView.backgroundColor = UIColor.white
        containerView.addSubview(toView!)
        containerView.addSubview(imageView)
        
        // Hide tapped cell image
        photoView?.isHidden = true
        
        UIView.animate(withDuration: duration,
                       delay:0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.4,
                       animations: {
                        fromView?.alpha = 0.0
                        toView?.alpha = 1.0
                        imageView.frame = finalFrame!
        }, completion:{_ in
            
            imageView.removeFromSuperview()
            
            if self.presenting {
                detailVC.imageScrollView.isHidden = false
            } else {
                self.dismissCompletion?()
            }
            
            transitionContext.completeTransition(true)
        })
    }
    
}
