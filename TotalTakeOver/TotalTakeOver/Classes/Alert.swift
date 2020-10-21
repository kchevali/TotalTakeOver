//
//  Alert.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/26/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import SpriteKit

class Alert: SKSpriteNode{
    
    var titleLabel: SKLabelNode
    var bodyLabel: SKLabelNode
    var button: SKSpriteNode
    var buttonLabel: SKLabelNode
    
    static var width: CGFloat = 0
    static var height: CGFloat = 0
    
    static func loadSize(_ width: CGFloat, _ height: CGFloat){
        Alert.width = 0.9*width
        Alert.height = 0.7*width
    }
    
    init(_ title: String, _ body: String, _ buttonText: String) {
        self.titleLabel = SKLabelNode(text: title.uppercased())
        self.bodyLabel = SKLabelNode(text:body)
        self.button = SKSpriteNode(texture: SKTexture(imageNamed: "alertWindow.png"), color: UIColor.clear, size: CGSize(width: 0.8*Alert.width,height: 70))
        self.buttonLabel = SKLabelNode(text:buttonText)
        super.init(texture: SKTexture(imageNamed: "alertWindow.png"), color: UIColor.clear, size: CGSize(width: 0.9*Alert.width,height: 0.7*Alert.width))
        
        zPosition = 1
        isUserInteractionEnabled = true
        
        titleLabel.position = CGPoint(x:0,y:Alert.height*0.3)
        titleLabel.fontColor = UIColor.black
        titleLabel.fontSize = 40
        titleLabel.zPosition = 1
        titleLabel.fontName = "Papyrus"
        addChild(titleLabel)
        
        bodyLabel.position =  CGPoint(x:0,y:Alert.height*0.15)
        bodyLabel.fontColor = UIColor.black
        bodyLabel.fontSize = 32
        bodyLabel.zPosition = 1
        bodyLabel.fontName = "Papyrus"
        bodyLabel.numberOfLines = 3
        addChild(bodyLabel)
        
        buttonLabel.position =  CGPoint(x:0,y:Alert.height * -0.3)
        buttonLabel.fontColor = UIColor.black
        buttonLabel.fontSize = 32
        buttonLabel.zPosition = 2
        buttonLabel.fontName = "Papyrus"
        addChild(buttonLabel)
        
        button.position =  CGPoint(x:0,y:Alert.height * -0.27)
        button.zPosition = 1
        addChild(button)
        
    }
    
    func push(){
        removeAllChildren()
        removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        print(location,button.position)
        if button.contains(location){
            removeAllChildren()
            removeFromParent()
            if let p = parent as? GameScene{
                p.alertWindow = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
