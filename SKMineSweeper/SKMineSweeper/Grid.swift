//
//  Grid.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 12/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode {
    
    init() {
  
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: 1600, height: 1600))
        
        self.position = CGPoint(x: UIScreen.main.bounds.size.width*2, y: UIScreen.main.bounds.size.height*2)
        
   
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
