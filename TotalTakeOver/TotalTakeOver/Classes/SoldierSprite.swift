//
//  Soldier.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/21/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import SpriteKit

class SoldierSprite: SKSpriteNode{
    
    static var frontTextures : [[SKTexture]] = []
    static var leftTextures : [[SKTexture]] = []
    static var rightTextures : [[SKTexture]] = []
    static var backTextures : [[SKTexture]] = []
    static var spinTextures : [[SKTexture]] = []
    static var deadTexture = SKTexture(imageNamed: "deadPlayerSNG_0")
    
    static let names = ["Boy","Man","Girl","Boss"]
    static let directions =  ["Front", "Left", "Right", "Back" ]
    static let steps =  [ "", "L", "","R" ]
    
    var x: Int
    var y: Int
    var rank: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
        self.rank = Soldier.startRank
        super.init(texture: SoldierSprite.frontTextures[rank][0], color: UIColor.clear, size: CGSize(width:32,height:32))
//        let animate = SKAction.animate(with: Soldier.allTextures[type][0], timePerFrame: 0.1)
//        self.run(SKAction.repeatForever(animate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func loadRunningTexture(_ direction: Int) -> [[SKTexture]]{
        var out : [[SKTexture]] = []
        for name in names{
            var textures : [SKTexture] = []
            for step in steps{
                textures.append(SKTexture(imageNamed: step + name + directions[0]+"_SNG_0.png"))
            }
            out.append(textures)
        }
        return out
    }
    
    static func loadAllTextures(){
        frontTextures = loadRunningTexture(0)
        leftTextures = loadRunningTexture(1)
        rightTextures = loadRunningTexture(2)
        backTextures = loadRunningTexture(3)
        
        spinTextures = []
        for name in names{
            var textures : [SKTexture] = []
            for direction in directions{
                textures.append(SKTexture(imageNamed:  name + direction + "_SNG_0.png"))
            }
            spinTextures.append(textures)
        }
    }

    func spin(){
        let animate = SKAction.animate(with: SoldierSprite.spinTextures[rank], timePerFrame: 0.1)
        self.run(SKAction.repeatForever(animate))
    }
    func walk(){
        let animate = SKAction.animate(with: SoldierSprite.frontTextures[rank], timePerFrame: 0.1)
        self.run(SKAction.repeatForever(animate))
    }
    func standStill(){
        removeAllActions()
        updateTexture()
    }
    func updateTexture(){
        texture = SoldierSprite.frontTextures[rank][0]

    }
    func isPlaced() -> Bool{
        return x >= 0 && y >= 0
    }
    
    func remove(){
        removeFromParent()
    }
}
