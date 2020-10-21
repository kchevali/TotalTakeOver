//
//  GameScene.swift
//  TileMaps
//
//  Created by Jonathan Parham on 1/22/18.
//  Copyright © 2018 Jonathan Parham. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var border = SKTileMapNode()
    var map = SKTileMapNode()
    
    var mapWidth=0, mapHeight=0, mapTileLength = 21
    var borderWidth=0, borderHeight=0, borderTileLength = 7
    var scaleX : CGFloat=0, scaleY : CGFloat = 0
    let borderTileSet = SKTileSet(named: "Boundary")!
    let blankTileSet = SKTileSet(named: "Blank")!
    
    let playerNumSelected = 0, playerNum = 1
    var cpuStart = 2, cpuEnd = 4//4
    
    var baseSprites : [BaseSprite] = []
    var soldierSprites : [SoldierSprite] = []
    var selectedSoldier : SoldierSprite? = nil{
        didSet{
            isCameraLocked = selectedSoldier != nil
        }
    }
    var selectedBase: BaseSprite? = nil
//    var runButton: SKSpriteNode!
    var buyButton: SKSpriteNode!
    var moneyLabel: SKLabelNode!
    var alertWindow: Alert? = nil{
        didSet{
            isCameraLocked = alertWindow != nil
        }
    }
    
    var previousCameraScale = CGFloat()
    var isCameraLocked = false
    var isCPUTurn = false
    
    //GAMEPLAYKIT
    var board: Board!
    var strategist = GKMinmaxStrategist()
    
    var baseLabels : [[SKLabelNode]] = []

    override func didMove(to view: SKView) {
        
        //CAMERA - SLIDING
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2, y: -size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        
        //CAMERA - ZOOM
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchGestureAction(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        //TEXTURES
        SoldierSprite.loadAllTextures()
        BaseSprite.loadTextures()
        
        //CREATE MAP
        map = self.childNode(withName: "Map") as! SKTileMapNode
        mapWidth = map.numberOfColumns
        mapHeight = map.numberOfRows
        scaleX = map.xScale
        scaleY = map.yScale
        Alert.loadSize(size.width, size.height)
        
        //CREATE BORDERS
        border = self.childNode(withName: "Borders") as! SKTileMapNode
        borderWidth = border.numberOfColumns
        borderHeight = border.numberOfRows
        
        //GAMEPLAY KIT
        Board.load(self)
        board = Board()
        board.resetBoard()
        updateGraphics()
        
        strategist.gameModel = board
        strategist.randomSource = GKARC4RandomSource()
        strategist.maxLookAheadDepth = 1
        
        buyButton = SKSpriteNode(texture: SoldierSprite.frontTextures[Soldier.startRank][0], color: UIColor.clear, size: CGSize(width:64,height:64))
        buyButton.position = CGPoint(x:frame.size.width-100,y:-frame.height+100)
        addChild(buyButton)
        
        moneyLabel = SKLabelNode(text: "$0")
        moneyLabel.position = CGPoint(x:frame.size.width-100,y:-frame.height+25)
        addChild(moneyLabel)
        
//        for x in 0..<mapWidth{
//            var col : [SKLabelNode] = []
//            for y in 0..<mapHeight{
//                let label = SKLabelNode(text: "\(board.findBase(x, y)?.UID ?? -1)")
//                if let center = getCenter(x,y){
//                    label.position = center
//                }
//                label.fontSize=16
//                label.fontColor = UIColor.red
//                label.zPosition = 1000
//                col.append(label)
//                addChild(label)
//            }
//            baseLabels.append(col)
//        }
        
        board.startTurn()
    }
    
//    func updateLabels(){
//        if baseLabels.count == 0{
//            return
//        }
//        for x in 0..<mapWidth{
//            for y in 0..<mapHeight{
//                let text  = "\(board.findBase(x, y)?.UID ?? -1)"
//                baseLabels[x][y].text = text
//            }
//        }
//    }
    
    @objc func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = self.camera else {
            return
        }
        if sender.state == .began {
            previousCameraScale = camera.xScale
        }
        camera.setScale(previousCameraScale * 1 / sender.scale)
    }
    
    func createAlert(_ title: String, _ body: String, _ button: String){
        let alert =  Alert(title, body, button)
        alert.position = CGPoint(x:size.width/2,y:-size.height/2)
        addChild(alert)
        
        alertWindow = alert
    }
    
    func getValidTiles() -> [[Bool]]{
        var out : [[Bool]] = []
        for x in 0..<mapWidth{
            var row: [Bool] = []
            for y in 0..<mapHeight{
                row.append(getCenter(x, y) != nil)
            }
            out.append(row)
        }
        return out
    }
    
    func setTile(_ num: Int, _ x: Int, _ y: Int){
        if let center = getCenter(x, y){
            border.setTileGroup(borderTileSet.tileGroups[num], forColumn: getBorderX(center.x), row: getBorderY(center.y))
        }
    }
    func setAllTileEmpty(_ num: Int){
        for x in 0..<borderWidth{
            for y in 0..<borderHeight{
                border.setTileGroup(blankTileSet.tileGroups[0], forColumn: x, row: y)
            }
        }
        for x in 0..<mapWidth{
            for y in 0..<mapHeight{
                if board.grid[x][y].playerId != num{
                    setTile(board.grid[x][y].playerId, x, y)
                }
            }
        }
    }

    func setTileForBase(_ base:Base, _ num: Int){
        for tile in base.tiles{
            setTile(num, tile.x, tile.y)
        }
    }
    
    func selectBase(_ x: Int, _ y: Int){
        if let baseSprite = findBaseSprite(x, y){
            let base = baseSprite.base
            if base.tiles.count > 1 && base.playerId == playerNum{
                selectedBase = baseSprite
                setTileForBase(base,playerNumSelected)
                baseSprite.animate(open: true)
                moneyLabel.text = "$\(base.money)"
                for soldierSprite in soldierSprites{
                    if base.hasVisited(soldierSprite.x,soldierSprite.y){
                        soldierSprite.walk()
                    }
                }
            }
        }else{
            print("No base sprite!")
        }
    }
    
    func unselectBase(){
        if let baseSprite = selectedBase{
            let base = baseSprite.base
            selectedBase = nil
            setTileForBase(base,playerNum)
            baseSprite.animate(open: false)
            moneyLabel.text = "$0"
            for soldierSprite in soldierSprites{
                if base.hasVisited(soldierSprite.x,soldierSprite.y){
                    soldierSprite.standStill()
                }
            }
        }
    }
    
    func pickUp(_ soldierSprite: SoldierSprite){
        soldierSprite.spin()
        selectedSoldier = soldierSprite
    }
    
    func createSoldier(_ location: CGPoint) -> Bool{
        if buyButton.contains(location){
            if let baseSprite = selectedBase{
                if baseSprite.base.canPurchase(){
                    let soldierSprite = SoldierSprite(-1,-1)
                    pickUp(soldierSprite)
                    addChild(soldierSprite)
                    return true
                }else{
                    createAlert("Insufficient Funds", "The cost is \(Soldier.costs[Soldier.startRank])!", "Ok")
                }
            }else{
                createAlert("No Base Selected", "Select an orange area", "Got it!")
            }
        }
        return false
    }

    
    func returnSoldier(_ soldierSprite: SoldierSprite){
        if let center = getCenter(soldierSprite.x, soldierSprite.y){
            soldierSprite.position = center
            soldierSprite.standStill()
        }
    }
    
    func findBaseSprite(_ x: Int, _ y: Int) -> BaseSprite?{
        for sprite in baseSprites{
            if sprite.base.hasVisited(x, y){
                return sprite
            }
        }
        return nil
    }
    
    func findSoldierSprite(_ x: Int, _ y: Int) -> SoldierSprite?{
        for sprite in soldierSprites{
            if sprite.x == x && sprite.y == y{
                return sprite
            }
        }
        return nil
    }
    
    func isPlayer(_ x: Int, _ y: Int) -> Bool{
        return board.grid[x][y].playerId == playerNum
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isCPUTurn{
            return
        }
        let location = touches.first!.location(in: self)
//        print("Clicked:",getMapX(location.x),getMapY(location.y))
        if createSoldier(location){
            return
        }

        unselectBase()
        if getCenter(location) != nil{
            let x = getMapX(location.x)
            let y = getMapY(location.y)
//            print("Click: ",x,y)
            if isPlayer(x,y){
                selectBase(x, y)
//                print("selectedBase is nil:",selectedBase == nil)
                if board.grid[x][y] is Soldier{
                    if let soldierSprite = findSoldierSprite(x, y){
                        pickUp(soldierSprite)
                    }
                }else{
//                    print("Tile is not a solider at: ",x,y)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isCPUTurn{
            return
        }
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        if let solider = selectedSoldier{
            solider.position = location
        }
        
        if isCameraLocked{
            return
        }
        let previousLocation = touch.previousLocation(in: self)
        
        camera?.position.x += previousLocation.x - location.x
        camera?.position.y += previousLocation.y - location.y
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isCPUTurn{
            return
        }
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        if let soldier = selectedSoldier{
            selectedSoldier = nil
            let x = getMapX(location.x)
            let y = getMapY(location.y)
            if soldier.x == x && soldier.y == y{
                returnSoldier(soldier)
                return
            }
            var move: Move
            if soldier.isPlaced(){
                if let baseSprite = selectedBase{
                    if board.canMove(baseSprite.base,(soldier.x,soldier.y), (x,y)){
                        move = Move(soldier.x,soldier.y,x,y)
                    }else{
                        createAlert("Invalid Move", "Please make a valid move", "Move Again")
                        returnSoldier(soldier)
                        return
                    }
                }else{
                    return
                }
            }else if let baseSprite = selectedBase,
                board.canPurchase(baseSprite.base, x,y){
                move = Move(x,y,nil,nil)
                soldier.removeFromParent()
            }else{
                soldier.removeFromParent()
                return
            }
            board.apply(move)
            if let baseSprite = selectedBase{
                moneyLabel.text = "$\(baseSprite.base.money)"
            }
            board.endTurn()
        }
        
    }
    
    func getMapX(_ x: CGFloat) -> Int{
        return Int(x/CGFloat(mapTileLength)/scaleX)
    }
    
    func getMapY(_ y: CGFloat) -> Int{
        return Int(CGFloat(mapHeight) + y / (CGFloat(mapTileLength)*scaleY))
    }
    
    func getBorderX(_ x: CGFloat) -> Int{
        return Int(x/CGFloat(borderTileLength)/scaleX)
    }
    
    func getBorderY(_ y: CGFloat) -> Int{
        return Int(CGFloat(borderHeight) + y / (CGFloat(borderTileLength)*scaleY))
    }
    
    func getCenter(_ x: Int, _ y: Int) -> CGPoint?{
        if let tileGroup = map.tileGroup(atColumn: x, row:y ){
            if tileGroup.rules.count != 13{
                let center = map.centerOfTile(atColumn: x, row: y)
                return CGPoint(x:center.x*scaleX,y:center.y*scaleY)
            }
        }
        return nil
    }
    
    func getCenter(_ pt: CGPoint) -> CGPoint?{
        return getCenter(getMapX(pt.x),getMapY(pt.y))
    }
    
    
    
    func animateStartTurn( _ num: Int){
        setAllTileEmpty(num)
//        border.alpha = 0.1
//        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 2.5)
        let wait = SKAction.wait(forDuration: 0.3)
        var sequence : [SKAction] = []
        for _ in 0..<2{
            sequence.append(SKAction.run({self.setAllTileEmpty(num)}))
            sequence.append(wait)
            sequence.append(SKAction.run({self.updateAllTiles()}))
            sequence.append(wait)
        }
        border.run(SKAction.sequence(sequence))
    }
    
    func updateGraphics(){
//        updateLabels()
        updateAllTiles()
        removeBaseSprites()
        removeSoldierSprites()
        addNewSprites()
    }
    
    func updateAllTiles(){
        for x in 0..<mapWidth{
            for y in 0..<mapHeight{
                setTile(board.grid[x][y].playerId, x, y)
            }
        }
    }
    
    func removeBaseSprites(){
        for i in 0..<baseSprites.count{
            let baseSprite = baseSprites[i]
            if !board.grid[baseSprite.x][baseSprite.y].isBase(){
                baseSprite.removeFromParent()
                baseSprites.remove(at: i)
                removeBaseSprites()
                return
            }
        }
    }
    
    func removeSoldierSprites(){
        for i in 0..<soldierSprites.count{
            let soldierSprite = soldierSprites[i]
            soldierSprite.standStill()
            if !board.grid[soldierSprite.x][soldierSprite.y].isSoldier(){
                soldierSprite.removeFromParent()
                soldierSprites.remove(at: i)
                removeSoldierSprites()
                return
            }
        }
    }
    func addNewSprites(){
        for x in 0..<mapWidth{
            for y in 0..<mapHeight{
                if let center = getCenter(x, y){
                    if let base = board.grid[x][y] as? Base, !findBaseAtPos(x, y){
                        //Add Base Sprite
                        let baseSprite = BaseSprite(base,x,y)
                        baseSprite.position = center
                        baseSprites.append(baseSprite)
                        addChild(baseSprite)
                    }else if board.grid[x][y].isSoldier(){
                        if let soldierSprite = findSoldierAtPos(x, y){
                            if let soldier = board.grid[x][y] as? Soldier, soldier.isDead{
                                soldierSprite.texture=SoldierSprite.deadTexture
                            }else{
                                soldierSprite.rank = board.grid[x][y].rank
                                soldierSprite.updateTexture()
                            }
                        }else{//Add Soldier Sprite
                            let soldierSprite = SoldierSprite(x,y)
                            soldierSprite.position = center
                            soldierSprite.rank = board.grid[x][y].rank
                            soldierSprite.updateTexture()
                            soldierSprites.append(soldierSprite)
                            addChild(soldierSprite)
                        }
                    }
                }
            }
        }
    }
    
    func findBaseAtPos(_ x: Int, _ y: Int)->Bool{
        for base in baseSprites{
            if base.x == x && base.y == y{
                return true
            }
        }
        return false
    }
    
    func findSoldierAtPos(_ x: Int, _ y: Int)->SoldierSprite?{
        for soldier in soldierSprites{
            if soldier.x == x && soldier.y == y{
                return soldier
            }
        }
        return nil
    }
    
    //Strategist
    func executeAIMove(){
        if let player = board.activePlayer, let move = strategist.bestMove(for: player) as? Move{
            board.apply(move)
        }
    }
    
//    func executeAIMove(){
//        if let player = board.activePlayer{
//            DispatchQueue.global().async { [unowned self] in
//                let strategistTime = CFAbsoluteTimeGetCurrent()
//                let move = self.strategist.bestMove(for: player) as? Move
//                let delta = CFAbsoluteTimeGetCurrent() - strategistTime
//
//                let aiTimeCeiling = 1.0
//                let delay = aiTimeCeiling - delta
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    if let move = move{
//                        self.board.apply(move)
//                    }
//                }
//            }
//            print("CPU MOVE:",move.src,move.dest)
//        }
//    }
    
//    func startAIMove() {
//        DispatchQueue.global().async { [unowned self] in
//            let strategistTime = CFAbsoluteTimeGetCurrent()
//            guard let column = self.columnForAIMove() else { return }
//            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
//
//            let aiTimeCeiling = 1.0
//            let delay = aiTimeCeiling - delta
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                self.makeAIMove(in: column)
//            }
//        }
//    }
   
}
