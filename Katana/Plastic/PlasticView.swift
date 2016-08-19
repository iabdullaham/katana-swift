//
//  PlasticView.swift
//  Katana
//
//  Created by Mauro Bolis on 16/08/16.
//  Copyright © 2016 Bending Spoons. All rights reserved.
//

import Foundation

private enum ConstraintX {
  case None, Left, Right, CenterX, Width
}

private enum ConstraintY {
  case None, Top, Bottom, CenterY, Height
}

public class PlasticView {
  public let key: String
  
  private(set) var frame: CGRect
  private(set) var absoluteOrigin: CGPoint
  private let multiplier: CGFloat
  private unowned let hierarchyManager: HierarchyManager
  
  private var oldestConstraintX = ConstraintX.None
  private var newestConstraintX = ConstraintX.None
  private var oldestConstraintY = ConstraintY.None
  private var newestConstraintY = ConstraintY.None
  
  private var constraintX: ConstraintX {
    get {
      return newestConstraintX
    }
    
    set(newValue) {
      oldestConstraintX = newestConstraintX
      newestConstraintX = newValue
    }
  }
  
  private var constraintY: ConstraintY {
    get {
      return newestConstraintY
    }
    
    set(newValue) {
      oldestConstraintY = newestConstraintY
      newestConstraintY = newValue
    }
  }

  convenience init(hierarchyManager: HierarchyManager, key: String, multiplier: CGFloat) {
    self.init(hierarchyManager: hierarchyManager, key: key, multiplier: multiplier, frame: CGRect.zero)
  }
  
  init(hierarchyManager: HierarchyManager, key: String, multiplier: CGFloat, frame: CGRect) {
    self.key = key
    self.frame = frame
    self.absoluteOrigin = frame.origin
    self.multiplier = multiplier
    self.hierarchyManager = hierarchyManager
  }
}

// MARK: Scalable methods
extension PlasticView {
  func scaleValue(_ value: Value) -> CGFloat {
    return value.scale(multiplier)
  }
}

// MARK: Update frame and absolute origin
extension PlasticView {
  private func updateHeight(_ newValue: CGFloat) -> Void {
    self.frame.size.height = newValue
  }
  
  private func updateWidth(_ newValue: CGFloat) -> Void {
    self.frame.size.width = newValue
  }
  
  private func updateX(_ newValue: CGFloat) -> Void {
    let relativeValue = self.hierarchyManager.getXCoordinate(newValue, inCoordinateSystemOfParentOfKey: self.key)
    self.frame.origin.x = relativeValue
    self.absoluteOrigin.x = newValue
  }
  
  private func updateY(_ newValue: CGFloat) -> Void {
    let relativeValue = self.hierarchyManager.getYCoordinate(newValue, inCoordinateSystemOfParentOfKey: self.key)
    self.frame.origin.y = relativeValue
    self.absoluteOrigin.y = newValue
  }
}

// MARK: Height
extension PlasticView {
  public var height: Value {
    get {
      return .fixed(self.frame.size.height)
    }
    
    set(newValue) {
      setHeight(newValue)
    }
  }
  
  private func setHeight(_ value: Value) {
    self.constraintY = .Height
    
    let newHeight = max(scaleValue(value), 0)
    var newTop = self.top.coordinate
    
    if (oldestConstraintY == .Bottom) {
      newTop = self.bottom.coordinate - newHeight
    
    } else if (oldestConstraintY == .CenterY) {
      newTop = self.centerY.coordinate - newHeight / 2.0
    }
    
    self.updateY(newTop)
    self.updateHeight(newHeight)
  }
}

// MARK: Width
extension PlasticView {
  public var width: Value {
    get {
      return .fixed(self.frame.size.width)
    }
    
    set(newValue) {
      setWidth(newValue)
    }
  }
  
  private func setWidth(_ value: Value) {
    self.constraintX = .Width
    
    let newWidth = max(scaleValue(value), 0)
    var newLeft = self.left.coordinate
    
    if (self.oldestConstraintX == .Right) {
      newLeft = self.right.coordinate - newWidth
    
    } else if (self.oldestConstraintX == .CenterX) {
      newLeft = self.centerX.coordinate - newWidth / 2.0
    }
    
    self.updateX(newLeft)
    self.updateWidth(newWidth)
  }
}

// MARK: Bottom
extension PlasticView {
  public var bottom: Anchor {
    get {
      return Anchor(kind: .Bottom, view: self)
    }
    
    set(newValue) {
      setBottom(newValue)
    }
  }
  
  public func setBottom(_ anchor: Anchor, _ offset: Value = Value.zero) -> Void {
    self.constraintY = .Bottom
    
    let newBottom = anchor.coordinate + scaleValue(offset)
    var newHeight = scaleValue(self.height)
    
    if (oldestConstraintY == .Top) {
      newHeight = max(newBottom - self.top.coordinate, 0)
    
    } else if (oldestConstraintY == .CenterY) {
      newHeight = max(2 * (newBottom - self.centerY.coordinate), 0)
    }
    
    self.updateY(newBottom - newHeight)
    self.updateHeight(newHeight)
  }
}

// MARK: Top
extension PlasticView {
  public var top: Anchor {
    get {
      return Anchor(kind: .Top, view: self)
    }
    
    set(newValue) {
      setTop(newValue)
    }
  }
  
  public func setTop(_ anchor: Anchor, _ offset: Value = Value.zero) -> Void {
    self.constraintY = .Top

    let newTop = anchor.coordinate + scaleValue(offset)
    var newHeight = scaleValue(self.height)
    
    if (self.constraintY == .Bottom) {
      newHeight = max(self.bottom.coordinate - newTop, 0)
    
    } else if (self.constraintY == .CenterY) {
      newHeight = max(2.0 * (self.centerY.coordinate - newTop), 0.0)
    }
    
    self.updateY(newTop)
    self.updateHeight(newHeight)
  }
}

// MARK: Right
extension PlasticView {
  public var right: Anchor {
    get {
      return Anchor(kind: .Right, view: self)
    }
    
    set(newValue) {
      setRight(newValue)
    }
  }
  
  public func setRight(_ anchor: Anchor, _ offset: Value = Value.zero) -> Void {
    self.constraintX = .Right;
    
    let newRight = anchor.coordinate + scaleValue(offset);
    var newWidth = scaleValue(self.width);
    
    if (self.oldestConstraintX == .Left) {
      newWidth = max(newRight - self.left.coordinate, 0.0);
    
    } else if (self.oldestConstraintX == .CenterX) {
      newWidth = max(2.0 * (newRight - self.centerX.coordinate), 0.0);
    }
    
    self.updateX(newRight - newWidth);
    self.updateWidth(newWidth)
  }
}

// MARK: Left
extension PlasticView {
  public var left: Anchor {
    get {
      return Anchor(kind: .Left, view: self)
    }
    
    set(newValue) {
      setLeft(newValue)
    }
  }
  
  public func setLeft(_ anchor: Anchor, _ offset: Value = Value.zero) -> Void {
    self.constraintX = .Left;
    
    let newLeft = anchor.coordinate + scaleValue(offset);
    var newWidth = scaleValue(self.width);
    
    if (self.oldestConstraintX == .Right) {
      newWidth = max(self.right.coordinate - newLeft, 0);
      
    } else if (self.oldestConstraintX == .CenterX) {
      newWidth = max(2.0 * (self.centerX.coordinate - newLeft), 0.0);
    }
    
    // update coords
    self.updateX(newLeft)
    self.updateWidth(newWidth)
  }
}

// MARK: CenterX
extension PlasticView {
  public var centerX: Anchor {
    get {
      return Anchor(kind: .CenterX, view: self)
    }
    
    set(newValue) {
      setCenterX(newValue)
    }
  }
  
  public func setCenterX(_ anchor: Anchor, _ offset: Value = Value.zero) -> Void {
    self.constraintX = .CenterX;
    
    let newCenterX = anchor.coordinate + scaleValue(offset);
    var newWidth = scaleValue(self.width);
    
    if (self.oldestConstraintX == .Left) {
      newWidth = max(2.0 * (newCenterX - self.left.coordinate), 0.0);
      
    } else if (self.oldestConstraintX == .Right) {
      newWidth = max(2.0 * (self.right.coordinate - newCenterX), 0.0);
    }
    
    // update coords
    self.updateX(newCenterX - newWidth / 2.0)
    self.updateWidth(newWidth)
  }
}

// MARK: CenterY
extension PlasticView {
  public var centerY: Anchor {
    get {
      return Anchor(kind: .CenterY, view: self)
    }
    
    set(newValue) {
      setCenterY(newValue)
    }
  }
  
  public func setCenterY(_ anchor: Anchor, _ offset: Value = Value.zero) -> Void {
    self.constraintY = .CenterY;
    
    let newCenterY = anchor.coordinate + scaleValue(offset);
    var newHeight = scaleValue(self.height);
    
    if (self.oldestConstraintY == .Top) {
      newHeight = max(2.0 * (newCenterY - self.top.coordinate), 0.0);
      
    } else if (self.oldestConstraintY == .Bottom) {
      newHeight = max(2.0 * (self.bottom.coordinate - newCenterY), 0.0);
    }
    
    // update coords
    self.updateY(newCenterY - newHeight / 2.0)
    self.updateHeight(newHeight)
  }
}


// MARK: Size
extension PlasticView {
  public var size: Size {
    get {
      return .fixed(self.frame.width, self.frame.height)
    }
    
    set(newValue) {
      self.height = newValue.height
      self.width = newValue.width
    }
  }
}