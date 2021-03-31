//
//  Flag.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 12/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

class Flag: SKSpriteNode {
    
    init(size_: CGSize, offset: CGFloat) {
  
        super.init(texture: SKTexture(imageNamed: "Flag"), color: UIColor.lightGray, size: size_)
        self.name = "Flag"
        self.position.y += offset
        self.zPosition = 3
   
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
