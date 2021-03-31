//
//  SettingsSliders.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 7/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import UIKit

class SettingsSlider: UISlider {
    
    
    init(max:Float, min:Float, sliderFrame:CGRect) {
        
        super.init(frame: sliderFrame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.maximumValue = max
        self.minimumValue = min
        self.tintColor = UIColor.black
        self.thumbTintColor = UIColor.blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
