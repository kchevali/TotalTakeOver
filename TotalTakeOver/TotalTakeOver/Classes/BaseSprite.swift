//
//  Bank.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/21/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import SpriteKit

class BaseSprite: SKSpriteNode{
    
    static var baseTextures : [SKTexture] = []
    static var reverseTextures : [SKTexture] = []
    
    static func loadTextures(){
        for i in 0..<4{
            baseTextures.append(SKTexture(imageNamed: "chest\(i)SNG_0.png"))
            reverseTextures.append(SKTexture(imageNamed: "chest\(3-i)SNG_0.png"))
        }
    }
    
    var x: Int
    var y: Int
    var base: Base

    init(_ base: Base, _ x: Int, _ y: Int){
        self.base = base
        self.x = x
        self.y = y
        super.init(texture: BaseSprite.baseTextures[0], color: UIColor.clear,size: CGSize(width:32,height:32))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(open: Bool){
        let animate = SKAction.animate(with: open ? BaseSprite.baseTextures : BaseSprite.reverseTextures, timePerFrame: 0.1)
        self.run(animate)
    }
}
