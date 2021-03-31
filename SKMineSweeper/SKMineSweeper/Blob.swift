//
//  Blob.swift
//  SKMineSweeper
//
//  Created by Brandon Thio on 31/1/20.
//  Copyright © 2020 Brandon Thio. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit // For RNG

class Blob: SKSpriteNode {
    
    var mine = false
    var revealed = false
    var flagged = false
    var justUnflagged = false
    var beingTouched = false
    var numNeighboringMines:Int!
    var rowIndex = 0
    var colIndex = 0
    var dimensions: CGFloat!
   
    // font list @ http://iosfonts.com/

    
    init(rowIndex: Int, colIndex: Int, blobsPerRow: Int) {
        
        self.rowIndex = rowIndex
        self.colIndex = colIndex
        self.dimensions = CGFloat(gridSize/blobsPerRow)

        
        
        super.init(texture: nil, color: UIColor.lightGray, size: CGSize(width: dimensions, height: dimensions))
        
        let offset = -CGFloat(gridSize/2) + self.size.width/2

        self.position.x =  offset + self.size.width*CGFloat(colIndex)

        self.position.y = offset + self.size.height * CGFloat(rowIndex)

        self.name = "\(rowIndex) \(colIndex)"
        
        self.drawBorder()
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBorder() {
        
        let border = SKShapeNode(rectOf: self.size)
        
        border.fillColor = UIColor.clear
        border.strokeColor = UIColor.black
        border.lineWidth = self.dimensions/15
        border.zPosition = 2
        border.isAntialiased = false
        self.addChild(border)
    }
    func addNumMinesLabel() {
        
        let numMinesLabel = SKLabelNode(fontNamed:"Avenir-Medium")

        numMinesLabel.fontColor = UIColor.black
        numMinesLabel.fontSize = self.size.width/1.5
        numMinesLabel.verticalAlignmentMode = .center
        numMinesLabel.isHidden = true
        numMinesLabel.name = "Num Mines Label"
 
        self.addChild(numMinesLabel)
    }
    
    func showNumMinesLabel() {
        if let label = self.childNode(withName: "Num Mines Label") as? SKLabelNode {
            
            label.isHidden = false
            if self.numNeighboringMines == 0 { label.text = "" }
            else { label.text = "\(Int(numNeighboringMines))" }
            
        }
    }
    
    func addMine() {
        
        let mine = Mine(size_: self.size)
        self.addChild(mine)
        
    }
    
    func showMine() {
        
        if let mine = self.childNode(withName: "Mine") as? SKSpriteNode {
            mine.zPosition = 1
        }
        
    }
    
    func addFlag() {
        

        let flag = Flag(size_: CGSize(width: self.size.width*1.5, height: self.size.height * 1.5), offset: self.size.height * 3)
        self.addChild(flag)
        
        flag.run(SKAction.group([SKAction.moveBy(x: 0, y: self.size.height * -3, duration: 0.1), SKAction.scale(to: self.size, duration: 0.1)]))
        
        self.flagged = true
        
    }
    func removeFlag() {
        //Check if there is a flag to remove
        if let flag = self.childNode(withName: "Flag") as? SKSpriteNode {
            flag.removeFromParent()
        }
        self.flagged = false
    }
}

func getRandomNumber(seed:Int) -> Double {

    // The Mersenne Twister is a very good algorithm for generating random
    // numbers, plus you can give it a seed...
    let rs = GKMersenneTwisterRandomSource()
    rs.seed = UInt64(seed)

    // Use the random source and a lowest and highest value to create a
    // GKRandomDistribution object that will provide the random numbers.
    let rd = GKRandomDistribution(randomSource: rs, lowestValue: 0, highestValue: 100)

    return Double(rd.nextInt())/100.0
    
}

func plantMines(blobArray:[[Blob]], numMines:Int, seed:Int) {
    
    var mineCount = 0
    var seedCounter = 0
    let maxIndex = blobArray.count - 1
    
    // Exclude corner blobs in number of blobs that are candidates for being mines
    let mineProbability = Double(numMines) / Double(blobArray.count * blobArray.count - 4)
    
    while mineCount < numMines {
        
        for row in blobArray {
            
            for blob in row {
                
                let i = blob.rowIndex
                let j = blob.colIndex
                
                // logic such that no mines at the corners
                if !((i == 0 && j == 0) || (i == 0 && j == maxIndex) || (i == maxIndex && j == 0) || (i == maxIndex && j == maxIndex)) {
                    
                    seedCounter += 1
                    //print(i,j)
                    if getRandomNumber(seed: seed + seedCounter) < mineProbability && !blob.mine {
                        
                        blob.mine = true
                        blob.addMine()
                        
                        mineCount += 1
                        
                        if mineCount == numMines {
                            return
                        }
                        
                    }
                }
                
            }
        }
    }
}
func getBlobs(blobsPerRow: Int, numMines: Int, seed:Int) -> [[Blob]] {
    
    let maxIndex = blobsPerRow - 1
    var generatedBlobArray = [[Blob]]()
    
    for rowIndex in 0...(maxIndex) {
        
        var blobRow = [Blob]()
        
        for colIndex in 0...(maxIndex) {
            
            let blob = Blob(rowIndex: rowIndex, colIndex: colIndex, blobsPerRow: blobsPerRow)
            
            
            blobRow.append(blob)
        }
        
        
        generatedBlobArray.append(blobRow)
    
    }
    
    plantMines(blobArray: generatedBlobArray, numMines: numMines, seed: seed)
    return generatedBlobArray
}

func getNumNeighbors(_ blobArray:[[Blob]]) -> Void {
    
    for eachRow in blobArray {
        
        for blob in eachRow {
            
            if blob.mine == false {
                
                // Check each non-mine blob's neighbour for mines
                
                var numNeighboringMines = 0
                
                
                for rowIndex in (blob.rowIndex - 1)...(blob.rowIndex + 1) {
                    
                    for colIndex in (blob.colIndex - 1)...(blob.colIndex + 1) {
                        
                        if rowIndex >= 0 && colIndex >= 0 && rowIndex < blobArray.count && colIndex < blobArray.count {
                            
                            if blobArray[rowIndex][colIndex].mine == true {
                                
                                numNeighboringMines += 1
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                blob.numNeighboringMines = numNeighboringMines
                
            }
            
        }
        
    }

}

func revealNonMineNeighbours(blob:Blob, blobArray:[[Blob]]) -> Void {
    
    for rowIndex in (blob.rowIndex - 1)...(blob.rowIndex + 1) {
        
        for colIndex in (blob.colIndex - 1)...(blob.colIndex + 1) {
            
            if rowIndex >= 0 && colIndex >= 0 && rowIndex < blobArray.count && colIndex < blobArray.count  {
                
                if blobArray[rowIndex][colIndex].mine == false {
                    
                    blobArray[rowIndex][colIndex].revealed = true
                    blobArray[rowIndex][colIndex].removeFlag()
                    
                }
            }
        }
    }
}
