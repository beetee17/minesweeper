//
//  SettingsButton.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 2/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

class SettingsButton: SKSpriteNode {
    
    let buttonSize = CGSize(width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.width*0.4)
    
    init() {
        
        super.init(texture: SKTexture(imageNamed: "Settings"), color: UIColor.blue, size: buttonSize)
        
        //Top Left
        self.position = CGPoint(x: -UIScreen.main.bounds.size.width*1.5, y: UIScreen.main.bounds.size.height*1.6)
        self.name = "Settings Button"
        self.zPosition = 5
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
