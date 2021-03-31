//
//  RestartButton.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 1/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

class RestartButton: SKSpriteNode {

    let buttonSize = CGSize(width: UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.width*0.5)
    
    init() {
        
        super.init(texture: SKTexture(imageNamed: "Smiley"), color: UIColor.yellow, size: buttonSize)
        
        self.position = CGPoint(x: 0, y: UIScreen.main.bounds.size.height*1.6)
        self.name = "Restart Button"
        self.zPosition = 5
    }
        
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
