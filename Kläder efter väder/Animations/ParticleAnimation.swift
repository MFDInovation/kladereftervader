//
//  ParticleAnimation.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-12-15.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

class AnimationParticle : NSObject, CAAnimationDelegate, StoppableAnimation {
    var superlayer: CALayer!
    var layer: CALayer!
    var animation: CAAnimation!
    var wind:Double!
    var particle: UIImage!
    var time: Double!
    private func r(_ max:CGFloat) -> CGFloat {
        return (CGFloat(arc4random()%10000)/10000)*max
    }
    
    func stop(){
        animation.delegate = nil
        animation = nil
        layer.removeAllAnimations()
        layer.removeFromSuperlayer()
    }
    
    func create(view: UIView, wind:Double, particle: UIImage, time:Double){
        self.superlayer = view.layer
        self.wind = wind
        self.particle = particle
        self.time = time
        return create(layer: view.layer, wind: wind, particle: particle, time: time, progress: r(1), repetitions: 0)
    }
    
    private func create(layer: CALayer, wind:Double, particle: UIImage, time:Double, progress: CGFloat, repetitions: Float){
        
        let startX = r(layer.bounds.width + layer.bounds.width * CGFloat(wind))
        let endX = startX - layer.bounds.width * CGFloat(wind)
        let startY = -r(20)-100
        let endY = layer.bounds.height
        let size = r(0.7)+0.3
        let rotation = atan2(startY-endY, startX-endX)
        let width = particle.size.width*size
        let height = particle.size.height*size
        
        let customPath = UIBezierPath()
        customPath.move(to: CGPoint(x: startX + (endX - startX) * progress,y: startY + (endY - startY) * progress))
        customPath.addLine(to: CGPoint(x: endX, y: endY))
        
        let movingLayer = CALayer()
        //layers.append(movingLayer)
        movingLayer.contents = particle.cgImage;
        movingLayer.anchorPoint = CGPoint.zero;
        movingLayer.frame = CGRect(x: -100, y: -100, width: width, height: height)
        movingLayer.transform = CATransform3DMakeRotation(rotation + CGFloat(Double.pi/2), 0, 0, 1)
        layer.addSublayer(movingLayer)
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = (Double(r(CGFloat(time))) + time)*Double(1-progress);
        pathAnimation.path = customPath.cgPath;
        pathAnimation.calculationMode = kCAAnimationLinear;
        pathAnimation.repeatCount = repetitions
        pathAnimation.delegate = self
        pathAnimation.isRemovedOnCompletion = false
        movingLayer.add(pathAnimation, forKey: "movingAnimation")
        animation = pathAnimation
        self.layer = movingLayer
    }
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if let animation = animation{
            animation.delegate = nil
            stop()
            create(layer: superlayer, wind: wind, particle: particle, time: time, progress: 0, repetitions: 1)
        }
    }
}
