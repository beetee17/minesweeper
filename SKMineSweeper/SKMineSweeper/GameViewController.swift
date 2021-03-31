//
//  GameViewController.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 31/1/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        if let view = self.view as! SKView? {
            
            let scene = GameScene(size: CGSize(width: view.bounds.width * 4, height: view.bounds.height*4))
            
            // Set the scale mode to scale to fit the window
 
            scene.scaleMode = .aspectFill
                
            // Present the scene
            view.presentScene(scene)

            view.showsFPS = true
            
        }
    }


}
