//
//  SettingsMenu.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 7/2/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit

extension UITextField {
    @objc func modifyClearButton(with image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(UITextField.clear(_:)), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .whileEditing
    }

    @objc func clear(_ sender : AnyObject) {
    if delegate?.textFieldShouldClear?(self) == true {
        self.text = ""
        sendActions(for: .editingChanged)
    }
}
}
class SettingsMenu : SKScene, UITextFieldDelegate {
    
    var newBlobsPerRow:Int!
    var newNumMines: Int!
    var newSeed:Int!
    
    // TODO: Clean this up (group by slider, not by step)
    let blobSliderFrame = CGRect(x: UIScreen.main.bounds.size.width/6, y: UIScreen.main.bounds.size.height*0.2, width: UIScreen.main.bounds.size.width/1.5, height: 70)
    var blobSlider:SettingsSlider!
    
    let mineSliderFrame = CGRect(x: UIScreen.main.bounds.size.width/6, y: UIScreen.main.bounds.size.height*0.35, width: UIScreen.main.bounds.size.width/1.5, height: 70)
    var mineSlider:SettingsSlider!
    
    var blobSliderValueLabel:SKLabelNode!
    var mineSliderValueLabel:SKLabelNode!
    var seedTextField:UITextField!

    override func didMove(to view: SKView) {
        
        let (seedText, seedTextField) = setUpSeedSetting()
        self.seedTextField = seedTextField
        
        self.backgroundColor = UIColor.white

        addChild(setUpTitleText())
        addChild(setUpBackButton())
        
        
        blobSlider = SettingsSlider(max: Float(100), min: Float(4.0), sliderFrame: blobSliderFrame)
        blobSlider.value = Float(UserDefaults.standard.integer(forKey: "blobs per row"))
        
        self.view?.addSubview(blobSlider)
        blobSlider.addTarget(self, action: #selector(handleBlobSlider), for: .valueChanged)
        
        mineSlider = SettingsSlider(max: Float(500), min: Float(1), sliderFrame: mineSliderFrame)
        mineSlider.value = Float(UserDefaults.standard.integer(forKey: "# of mines"))
        
        self.view?.addSubview(mineSlider)
        mineSlider.addTarget(self, action: #selector(handleMineSlider), for: .valueChanged)
        

        addChild(seedText)
        addChild(setUpSliderLabels(slider: blobSlider, label: "Blobs Per Row"))
        addChild(setUpSliderLabels(slider: mineSlider, label: "# of Mines"))
        
        blobSliderValueLabel = setUpSliderValueLabels(slider: blobSlider)
        mineSliderValueLabel = setUpSliderValueLabels(slider: mineSlider)
        
        
  
        self.view?.addSubview(self.seedTextField)
                
        addChild(blobSliderValueLabel)
        addChild(mineSliderValueLabel)

        let modeButtons = setUpModeButtons()
        
        for button in modeButtons {
            addChild(button)
        }
      
    }
 

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("EDITING ENDED")
        let changedSeed:Int? = Int(textField.text!)
        print(changedSeed)
        // Check if input is an Int
        if changedSeed == nil || changedSeed ?? -1 <= 0 {
            textField.text = "ERROR"
            textField.becomeFirstResponder()
        }
        else {

            //Update seed value
            newSeed = Int(textField.text!)
        }

        print(newSeed)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Hides the keyboard
        
        textField.resignFirstResponder()
        
        return true
    }
    override func update(_ currentTime: TimeInterval) {
        
        mineSlider.maximumValue = (blobSlider.value*blobSlider.value - 4.0) / 2
        

    }
    @objc func handleBlobSlider() {
        
        newBlobsPerRow = Int(blobSlider.value)
        blobSliderValueLabel.text = "\(newBlobsPerRow!)"
    }
    
    @objc func handleMineSlider() {
        
        
        newNumMines = Int(mineSlider.value)
        mineSliderValueLabel.text = "\(newNumMines!)"
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchCount = touches.count
        if touchCount > 0 {
            if let touch = touches.first {
                
                
                let touchLocation = touch.location(in: self)
                
                let nodesTouched = self.nodes(at: touchLocation)
                if nodesTouched.count == 0  {

                    //Hides the keyboard
                    
                    seedTextField.resignFirstResponder()
                    
                }
                for node in nodesTouched {
                    
                    if let button = node as? SKShapeNode {
                        
                        // A Mode Button was touched
                        let modes = ["Easy" : [9, 10],
                                     "Medium" : [16, 40],
                                     "Hard" : [30, 200]]
                        
                        for (mode, settings) in modes {
                            
                            if button.name == mode {
                                
                                mineSlider.maximumValue = Float((settings[1]*settings[1] - 4) / 2)
                                blobSlider.setValue(Float(settings[0]), animated: true)
                                mineSlider.setValue(Float(settings[1]), animated: true)
                                handleBlobSlider()
                                handleMineSlider()
                            }
                            
                        }
                    
                    }
                    let nodeName = node.name
                    
                    if nodeName == "Back Button" {
                        
                        // User has touched back button
                        returnToGame()
                    }
                        
                    if nodeName == "seed input" {
                        seedTextField.becomeFirstResponder()

                    }

                }
            }

        }
    }

    func setUpTitleText() -> SKLabelNode {
            
        let menuTitle = SKLabelNode(fontNamed: "Avenir-Medium")

        menuTitle.isHidden = false
        menuTitle.fontColor = UIColor.black
        menuTitle.fontName = "Futura"
        menuTitle.fontSize = UIScreen.main.bounds.size.width/2
        menuTitle.verticalAlignmentMode = .center
        menuTitle.position = CGPoint(x: UIScreen.main.bounds.size.width*2, y: UIScreen.main.bounds.size.height*3.6)
        menuTitle.zPosition = 2
        menuTitle.text = "Settings"
        
        return menuTitle

    }
    
    func setUpModeButtons() -> [SKShapeNode] {
        
        var buttons = [SKShapeNode]()
        let modes:KeyValuePairs = ["Easy" : UIColor.green,
                     "Medium" : UIColor.yellow,
                     "Hard" : UIColor.red]
        let buttonSize = CGSize(width: UIScreen.main.bounds.size.width*1.4, height: UIScreen.main.bounds.size.height*0.25)
        let topButtonPosition = CGPoint(x: UIScreen.main.bounds.size.width*2 - buttonSize.width/2, y: UIScreen.main.bounds.size.height*1.1)
        
        
        var index = CGFloat(0)
        
        for (mode, color) in modes {

            let roundedRectPath = UIBezierPath(roundedRect: CGRect(origin: topButtonPosition, size: buttonSize), cornerRadius: 20)

            let modeButton = SKShapeNode(path: roundedRectPath.cgPath)
            modeButton.fillColor = color
            modeButton.strokeColor = .black
            modeButton.lineWidth = 5
            modeButton.name = mode
            modeButton.position.y -= UIScreen.main.bounds.size.height*0.35*index
            
            
            let buttonLabel = SKLabelNode(fontNamed: "Avenir-Medium")
            buttonLabel.fontSize = UIScreen.main.bounds.size.width/3
            buttonLabel.fontColor = UIColor.black
            buttonLabel.verticalAlignmentMode = .center
            buttonLabel.text = mode
            buttonLabel.zPosition = 1
            
            buttonLabel.position.x = topButtonPosition.x + buttonSize.width/2
            buttonLabel.position.y = topButtonPosition.y + buttonSize.height/2
                       
            
            modeButton.addChild(buttonLabel)

            
            index += 1
            buttons.append(modeButton)
        }
        return buttons
    }
    
    
    
    func setUpBackButton() -> SKLabelNode {
       
            
        let backButton = SKLabelNode(fontNamed: "Avenir-Medium")
        
        backButton.name = "Back Button"
        backButton.isHidden = false
        backButton.fontColor = UIColor.blue
        backButton.fontSize = UIScreen.main.bounds.size.width/3
        backButton.verticalAlignmentMode = .center
        backButton.position = CGPoint(x: 200, y: UIScreen.main.bounds.size.height*3.64)
        backButton.zPosition = 2
        backButton.text = "Back"
        
        return backButton
            
        
    }
    
    func returnToGame() {
        
        // Save game settings
        UserDefaults.standard.set(blobSlider.value, forKey: "blobs per row")
        UserDefaults.standard.set(mineSlider.value, forKey: "# of mines")
        
        // TODO: Makesliders transit with rest of screen
        
        blobSlider.removeFromSuperview()
        mineSlider.removeFromSuperview()
        //seedSlider.removeFromSuperview()
        seedTextField.removeFromSuperview()
        
        //TODO: If no change in settings, "unpause game"
        
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        
        if let changedBlobs = newBlobsPerRow as? Int {
            gameScene.blobsPerRow = changedBlobs
            print(changedBlobs)
        }
        
        if let changedMines = newNumMines as? Int {
            gameScene.numMines = changedMines
            print(changedMines)
        }
        
        gameScene.seed = newSeed

        self.view?.presentScene(gameScene, transition: SKTransition.flipVertical(withDuration: 0.5))
        
    }
    
    func setUpSliderLabels(slider:SettingsSlider, label:String) -> SKLabelNode {
            
        let sliderLabel = SKLabelNode(fontNamed: "Avenir-Medium")

        sliderLabel.isHidden = false
        sliderLabel.fontColor = UIColor.black
        sliderLabel.fontName = "Futura"
        sliderLabel.fontSize = UIScreen.main.bounds.size.width/4
        sliderLabel.verticalAlignmentMode = .center
        sliderLabel.position = CGPoint(x: UIScreen.main.bounds.size.width * 2, y: (UIScreen.main.bounds.size.height - slider.frame.minY) * 4)
        sliderLabel.zPosition = 2
        sliderLabel.text = label
        
        return sliderLabel

    }
    

    
    func setUpSliderValueLabels(slider:SettingsSlider) -> SKLabelNode {
        
        let sliderValueLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        
        sliderValueLabel.isHidden = false
        sliderValueLabel.fontColor = UIColor.black
        sliderValueLabel.fontName = "Futura"
        sliderValueLabel.fontSize = UIScreen.main.bounds.size.width/4
        sliderValueLabel.verticalAlignmentMode = .center
        sliderValueLabel.position = CGPoint(x: UIScreen.main.bounds.size.width * 2, y: (UIScreen.main.bounds.size.height - slider.frame.maxY) * 4)
        sliderValueLabel.zPosition = 2
        sliderValueLabel.text = "\(Int(slider.value))"
        
        return sliderValueLabel
        
    }
    
    func setUpSeedSetting() -> (SKLabelNode, UITextField) {
    
        
        let seedText = SKLabelNode(fontNamed: "Avenir-Medium")

        seedText.isHidden = false
        seedText.fontColor = UIColor.black
        seedText.fontName = "Futura"
        seedText.fontSize = UIScreen.main.bounds.size.width/4
        seedText.verticalAlignmentMode = .center
        seedText.position = CGPoint(x: UIScreen.main.bounds.size.width * 2, y: UIScreen.main.bounds.size.height * 2)
        seedText.zPosition = 2
        seedText.text = "RNG Seed"
        
        let seedTextFieldPos = self.convertPoint(toView: CGPoint(x: UIScreen.main.bounds.size.width * 2, y: UIScreen.main.bounds.size.height * 1.8))
        let fieldWidth = CGFloat(250)
        let fieldHeight = CGFloat(50)
        let seedTextField = UITextField(frame: CGRect(x: seedTextFieldPos.x - fieldWidth/2, y: seedTextFieldPos.y - fieldHeight/2, width: fieldWidth, height: fieldHeight))
        seedTextField.delegate = self
        seedTextField.text = "\(Int(newSeed))"
        seedTextField.font = UIFont(name: "Futura", size: UIScreen.main.bounds.size.width/16)
        seedTextField.backgroundColor = .white
        seedTextField.textColor = .black
        seedTextField.textAlignment = .center
        seedTextField.clearButtonMode = .whileEditing
//        seedTextField.modifyClearButton(with image: "clear")
        seedTextField.clearsOnBeginEditing = false
        seedTextField.borderStyle = .roundedRect


        return (seedText, seedTextField)
        
    }
}

