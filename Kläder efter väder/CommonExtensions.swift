//
//  CommonExtensions.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

//Safe index operator(returns nil instead of exception)
extension Collection {
    public subscript(safe index: Index) -> _Element? {
        return index >= startIndex && index < endIndex
            ? self[index]
            : nil
    }
}
//Safe index operator(returns nil instead of exception)
extension NSArray{
    
    //It is not possible to overload subscript on an NSArray the same
    //way as Collection since it would produce a name collision for objc code
    public func safeObject(at index: Int) -> Any? {
        return index >= 0 && index < self.count
            ? self.object(at: index)
            : nil
    }
}

extension NSLayoutConstraint{
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.isActive = true
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
