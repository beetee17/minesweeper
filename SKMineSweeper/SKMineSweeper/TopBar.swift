//
//  TopBar.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 3/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

class TopBar: SKSpriteNode {
    
    init() {
        
        super.init(texture: nil, color: UIColor.black, size: CGSize(width: UIScreen.main.bounds.size.width*4, height: UIScreen.main.bounds.size.height*0.6))
        
        //self.position = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height*0.9)
        self.position = CGPoint(x: 0, y: UIScreen.main.bounds.size.height*1.7)
        self.isUserInteractionEnabled = true
        self.zPosition = 4
    
    }
        
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
