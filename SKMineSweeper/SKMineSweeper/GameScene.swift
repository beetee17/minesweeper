//
//  GameScene.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 31/1/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import SpriteKit
import Foundation

class GameScene: SKScene, UIGestureRecognizerDelegate {
    
    var grid = Grid()
    var blobArray:[[Blob]]!
    var blobsPerRow = 9
    var numMines = 10
    var seed = Int.random(in: 1...1000000)
    var maxZoom:Double!
    
    let restartButton = RestartButton()
    let replayButton = addReplayButton()
    
    let settingsButton = SettingsButton()
    let topBar = TopBar()
    let progressLabel = addProgressLabel()
    
    let stopwatchLabel = addStopwatchLabel()
    var timeElapsed = 0
    var stopwatch:SKAction!
    
    var gameOver = false
    
    var touchDuration = 0
    var longPressDetected = false
    var touchMoved = false
    
    var upperBound = CGFloat(UIScreen.main.bounds.size.height*1.6)
    var lowerBound = CGFloat(UIScreen.main.bounds.size.height*2.8)
    var rightBound = CGFloat(UIScreen.main.bounds.size.width * 4)
    var leftBound = CGFloat(0)
    
    // Initialise sound effects
    let revealSounds = [SKAction.playSoundFileNamed("RevealSound1.wav", waitForCompletion: false),
                        SKAction.playSoundFileNamed("RevealSound2.wav", waitForCompletion: false)]
    let flagSound = SKAction.playSoundFileNamed("FlagSound.wav", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("GameOverSound.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        if UserDefaults.standard.integer(forKey: "blobs per row") != 0 {
            
            self.blobsPerRow = UserDefaults.standard.integer(forKey: "blobs per row")
            self.numMines = UserDefaults.standard.integer(forKey: "# of mines")

        }
        
        addChild(self.grid)
        
        blobArray = getBlobs(blobsPerRow: self.blobsPerRow, numMines: self.numMines, seed: self.seed)
        print(self.seed)
        
        getNumNeighbors(blobArray)
        
        self.maxZoom = getMaxZoom(blobArray: blobArray)

        
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        cameraNode.zPosition = 1

        addChild(cameraNode)
        self.camera = cameraNode
        
        
        self.view?.isUserInteractionEnabled = true
        self.view?.isMultipleTouchEnabled = true

        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchFrom(_:)))
        pinchGestureRecognizer.delegate = self
        self.view?.addGestureRecognizer(pinchGestureRecognizer)

        
        self.camera?.addChild(restartButton)
        self.camera?.addChild(settingsButton)
        self.camera?.addChild(stopwatchLabel)
        self.camera?.addChild(topBar)
        self.camera?.addChild(progressLabel)
        self.camera?.addChild(replayButton)
        
        self.stopwatch = getStopwatch()
        
        for row in blobArray {
            
            for blob in row {
                
                grid.addChild(blob)
                blob.addNumMinesLabel()

            }
        }
        setCamConstraint(1.0)


    }
    
    
    func setCamConstraint(_ scale:CGFloat) {
        
        let gridRect = grid.calculateAccumulatedFrame()
        
        let cameraConstraintRect = gridRect.insetBy(dx: -0.01/scale, dy: -0.01/scale)
        
        let xRange = SKRange(lowerLimit: cameraConstraintRect.minX, upperLimit: cameraConstraintRect.maxX)
        let yRange = SKRange(lowerLimit: cameraConstraintRect.minY, upperLimit: cameraConstraintRect.maxY)
        self.camera!.constraints = [SKConstraint.positionX(xRange, y: yRange)]

    }
    
    //MARK: - Find out how/why this works
    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        
        if sender.numberOfTouches == 2 {
            
            let locationInView = sender.location(in: self.view)
            let location = self.convertPoint(fromView: locationInView)
            
            if sender.state == .changed {
                
                let convertedScale = 1/sender.scale
                let newScale = self.camera!.xScale*convertedScale
                print(newScale)
                
                
                //TODO: Constrain such that max zoom makes blob size same as 9x9
                if Double(newScale) > self.maxZoom && Double(newScale) < 1.1  {

                    self.camera!.setScale(newScale)

                    setCamConstraint(newScale)

                }
                
                let locationAfterScale = self.convertPoint(fromView: locationInView)
                let locationDelta = CGPoint(x: location.x - locationAfterScale.x, y: location.y - locationAfterScale.y)
                
                let newPoint = CGPoint(x: self.camera!.position.x + locationDelta.x, y: self.camera!.position.y + locationDelta.y)
                
                self.camera!.position = newPoint
                sender.scale = 1.0
            }

        }
    }
    
    func getMaxZoom(blobArray:[[Blob]]) -> Double {
        
        let sampleBlob = Blob(rowIndex: 0, colIndex: 0, blobsPerRow: 8)
        
        return pow(Double(blobArray[0][0].size.width/sampleBlob.size.width), 2)
    }
    

    // MARK: - UPDATE LOOP
    
    override func update(_ currentTime: TimeInterval) {
        
        if !self.view!.isPaused {

            let (flagsLeft, minesRevealed) = updateBlobArray(blobArray: self.blobArray)
            

            if minesRevealed == numMines { victory() }
            
            
            if self.gameOver { presentGameOver() }
            
            self.progressLabel.text = "\(Int(flagsLeft))"
            
        }
    }
    
    func getStopwatch() -> SKAction {
        
        let SKwait = SKAction.wait(forDuration: 1)
        let SKrun = SKAction.run({
            self.timeElapsed += 1
            self.stopwatchLabel.text = "\(Int(self.timeElapsed))"
        })
        
        return SKAction.repeatForever(SKAction.sequence([SKwait, SKrun]))
        
    }

    func restartGame() {
        
        // Save current settings
        let currBlobsPerRow = self.blobsPerRow
        let currNumMines = self.numMines
        
        // For 'multiplayer' purposes
        let currSeed = self.seed
        
        let newScene = GameScene(size: self.size)
        newScene.seed = currSeed + 300
        newScene.scaleMode = self.scaleMode
        
        // Reload scene with most recent settings
        newScene.blobsPerRow = currBlobsPerRow
        newScene.numMines = currNumMines
        
        self.view?.presentScene(newScene)
        
    }
    
    func replayGrid() {
        
        // Save current settings
        let currBlobsPerRow = self.blobsPerRow
        let currNumMines = self.numMines
        let currSeed = self.seed
        
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        
        // Reload scene with most recent settings
        newScene.blobsPerRow = currBlobsPerRow
        newScene.numMines = currNumMines
        newScene.seed = currSeed
        
        self.view?.presentScene(newScene)
        
    }
    
    func presentSettings() {
        
        //Save current game settings
        UserDefaults.standard.set(self.blobsPerRow, forKey: "blobs per row")
        UserDefaults.standard.set(self.numMines, forKey: "# of mines")
        
        let settingsScene = SettingsMenu(size: self.size)
        settingsScene.newSeed = self.seed
        settingsScene.scaleMode = self.scaleMode
        self.view?.presentScene(settingsScene, transition: SKTransition.flipVertical(withDuration: 0.5)) //SKTransition.reveal(with: SKTransitionDirection(rawValue: 0)!, duration: 1))
        
    }
    func presentGameOver() {
        
        // Change Restart Button to sad face
        self.restartButton.texture = SKTexture(imageNamed: "GameOver")
        
        // behaviour when gameOver is true (for now, reveal all blobs)
        for row in self.blobArray {
            
            for blob in row {
                
                if !(blob.mine && blob.flagged) {
                    // Only reveal blobs that were (a) not mines and (b) incorrectly identified as mines
                    blob.revealed = true
                    
                }
            }
        }
       
        self.removeAction(forKey: "stopwatch")

    }
    
    func victory() {
        
        // for now, reveal all blobs
        for row in self.blobArray {
            
            for blob in row {
                
                if !(blob.mine && blob.flagged) {
                    // Only reveal blobs that were (a) not mines and (b) incorrectly identified as mines
                    blob.revealed = true
                    
                }
            }
        }
        
        self.removeAction(forKey: "stopwatch")
    }
    
    func updateBlobArray(blobArray:[[Blob]]) -> (Int, Int) {
    
        var flagsLeft = self.numMines
        var minesRevealed = 0
        for row in blobArray {
            
            for blob in row {
                
                switch blob.revealed {
                    
                case true:
                    // blob has been revealed
                    
                    switch blob.mine {
                        
                    case true:
                        // mine has been revealed
                      
                        blob.showMine()
                        self.gameOver = true
                        
                    case false:
                        // non - mine revealed
                        
                        blob.color = UIColor.white
                        blob.showNumMinesLabel()
                        
                        if blob.numNeighboringMines == 0 {
                            
                            //reveal non-mine neighbors
                            revealNonMineNeighbours(blob: blob, blobArray: blobArray)
                        }
                    }
                    
                case false:
                    // blob not revealed yet
                    switch blob.flagged {
                        
                    case true:
                        // blob is flagged
           
                        if blob.mine {
                            // mine was flagged
                            minesRevealed += 1
                            
                        }
                        
                        flagsLeft -= 1
                        
                        
                    case false:
                        // blob not flagged
                        blob.color = UIColor.lightGray
                        blob.removeFlag()
                        
                        
                    }
                    
                    if blob.beingTouched {
                        self.touchDuration += 1
                        
                        if self.touchDuration == longPressDuration {
                            //long-press detected, reset touchDuration
                            
                            if self.touchMoved == false && flagsLeft != 0 {
                                // Limit # of flags placed in total to # of mines
                                switch blob.flagged {
                                    //toggle flag
                                    
                                case true:
                                    
                                    blob.removeFlag()
                                    blob.justUnflagged = true
                                    
                                case false:
                                    blob.addFlag()
                                    //self.run(flagSound)
                                }
                            }
                        }
                    }
                }
            }
        }
        return (flagsLeft, minesRevealed)
    }
    
    // MARK: - TOUCH HANDLING
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("BEGAN")
        self.touchDuration = 0
        self.touchMoved = false
        
        let touchCount = touches.count
        if touchCount == 1 {

            
            if let touch = touches.first {
                
                let touchLocation = touch.location(in: self)
                
                let nodesTouched = self.nodes(at: touchLocation)
                
                for node in nodesTouched {
                    
                    let nodeName = node.name
                    
                    if let blob = node as? Blob {
                        
                        // User as touched a Blob
                        if let indexArr = nodeName?.components(separatedBy: " ") as? [String] {
                            
                            let rowIndex = Int(indexArr[0])!
                            let colIndex = Int(indexArr[1])!
                            let blob_ = blobArray[rowIndex][colIndex]
                            blob_.beingTouched = true
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("ENDED")
        
        let touchCount = touches.count
        if touchCount > 0 {
            
            if let touch = touches.first {
                
                let touchLocation = touch.location(in: self)
                
                let nodesTouched = self.nodes(at: touchLocation)
                
                for node in nodesTouched {
                    
                    let nodeName = node.name
                    
                    if nodeName == "Restart Button" {
                        
                        // User has touched restart button -> restart a new game
                        restartGame()
                        
                    }
                    else if nodeName == "Replay Button" {
                        
                        // User has touched replay button -> replay same grid
                        replayGrid()
                    }
                        
                    else if nodeName == "Settings Button" {
                        
                        // User has touched settings button -> transit to settings menu
                        presentSettings()
                        
                    }
                        
                    else {
                        
                        if let blob_ = node as? Blob {
                            
                            // User has touched a Blob
                            
                            if self.timeElapsed == 0 && !self.touchMoved{
                                
                                // User has started game, start stopwatch
                                
                                self.run(self.stopwatch, withKey: "stopwatch")
                                
                            }
                            
                            if let indexArr = nodeName?.components(separatedBy: " ") as? [String] {
                                
                                let rowIndex = Int(indexArr[0])!
                                let colIndex = Int(indexArr[1])!
                                let blob_ = blobArray[rowIndex][colIndex]
                                
                                if !(blob_.flagged || blob_.justUnflagged || self.touchMoved) && !blob_.revealed {
                                    
                                    blob_.revealed = true
                                    if blob_.mine {
                                        //self.run(gameOverSound)
                                    }
                                    else {
                                        
                                        
                                        //self.run(revealSounds[Int.random(in: 0...1)])
                                    }
                                    
                                }
                                
                            }
                            
                            blob_.beingTouched = false
                            blob_.justUnflagged = false
                        }
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("CANCELLED")
        
        // Prevent blobs from being revealed/flagged
        for row in blobArray {
            
            for blob in row {
                
                blob.beingTouched = false

            }
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let touchLocation = touch.location(in: self.view)
            let previousTouchLocation = touch.previousLocation(in: self.view)
            

            
            // Increase granularity of scrolling as zoom increases
            let deltaX = (previousTouchLocation.x - touchLocation.x) * 4 * self.camera!.xScale
            let deltaY = (touchLocation.y - previousTouchLocation.y) * 4 * self.camera!.xScale
            
            self.camera!.position.y += deltaY
            self.camera!.position.x += deltaX
          // Prevent blobs from being revealed/flagged
          
            if abs(deltaX) + abs(deltaY) > 5.0 {
              self.touchMoved = true
              print("MOVED")
              for row in blobArray {
                  
                  for blob in row {
                      
                      blob.beingTouched = false

                  }
              }
            }
            
        }
    }
}
    



// MARK: - UTILITY FUNCTIONS

func addReplayButton() -> SKSpriteNode{
    
    let replayButton = RestartButton()
    
    replayButton.texture = SKTexture(imageNamed: "Replay")
    replayButton.size = CGSize(width: UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.width*0.5)
    replayButton.name = "Replay Button"
    //Top Right
    replayButton.position = CGPoint(x: UIScreen.main.bounds.size.width*1.5, y: UIScreen.main.bounds.size.height*1.6)
    replayButton.color = UIColor.green
    
    
    return replayButton
}

func addStopwatchLabel() -> SKLabelNode {
    
    let label = SKLabelNode(fontNamed: "Avenir-Medium")
    
    label.isHidden = false
    label.fontColor = UIColor.red
    label.fontSize = UIScreen.main.bounds.size.width/3
    label.verticalAlignmentMode = .center
    label.position = CGPoint(x: UIScreen.main.bounds.size.width*0.8, y: UIScreen.main.bounds.size.height*1.6)
    label.text = "0"
    label.zPosition = 5
    
    return label
    
}

func addProgressLabel() -> SKLabelNode {
    
    let label = SKLabelNode(fontNamed: "Avenir-Medium")
    
    label.isHidden = false
    label.fontColor = UIColor.orange
    label.fontSize = UIScreen.main.bounds.size.width/3
    label.verticalAlignmentMode = .center
    label.position = CGPoint(x: -UIScreen.main.bounds.size.width*0.8, y: UIScreen.main.bounds.size.height*1.6)
    label.zPosition = 5
    
    return label
    
}

