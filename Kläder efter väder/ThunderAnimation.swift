//
//  ThunderAnimation.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-12-15.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

class ThunderAnimation: NSObject, StoppableAnimation {
    var imageView: UIView? = nil
    var superView: UIView? = nil
    var width:CGFloat = 0
    var height:CGFloat = 0
    private func r(_ max:CGFloat) -> CGFloat {
        return (CGFloat(arc4random()%10000)/10000)*max
    }
    
    func stop(){
        imageView?.superview?.layer.removeAllAnimations()
        imageView?.removeFromSuperview()
    }
    
    func create(view: UIView){
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lightning"))
        self.imageView = imageView
        self.superView = view
        imageView.alpha = 0
        view.addSubview(imageView)
        width = imageView.frame.width
        height = imageView.frame.height
        
        animate(imageView: imageView,time: Double(self.r(3)))
        
    }
    func animate(imageView:UIView, time : Double){
        let scale = 1 + self.r(1)
        let x = self.superView!.frame.width/4 + self.r(self.superView!.frame.width/2)-imageView.frame.width*scale/2
        imageView.frame = CGRect(x: x, y: 0, width: width*scale, height: height*scale)
        UIView.animate(withDuration: time, animations: { imageView.alpha = 0.01}, completion: {_ in
            UIView.animate(withDuration: 0.1, animations: { imageView.alpha = 1}, completion: {_ in
                UIView.animate(withDuration: 0.2, animations: { imageView.alpha = 0.3}, completion: {_ in
                    UIView.animate(withDuration: 0.1, animations: { imageView.alpha = 1}, completion: {_ in
                        UIView.animate(withDuration: 0.8, animations: { imageView.alpha = 0}, completion: {_ in
                            self.animate(imageView: imageView,time: Double(self.r(2)+5))
                        })
                    })
                })
            })
        })
    }
}
