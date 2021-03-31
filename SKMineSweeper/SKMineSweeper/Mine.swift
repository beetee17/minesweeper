//
//  Mine.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 13/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

class Mine: SKSpriteNode {

    
    init(size_: CGSize) {
  
        super.init(texture: SKTexture(imageNamed: "Mine1"), color: UIColor.red, size: size_)
        self.name = "Mine"
        self.zPosition = -1
        self.getTexture()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTexture() {
        
        if Double.random(in: 0.0...1.0) < 0.5 {
            self.texture = SKTexture(imageNamed: "Mine2")
        }
        
    }
    
}
