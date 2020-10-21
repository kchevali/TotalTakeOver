////
////  Bank.swift
////  TileMaps
////
////  Created by Kevin Chevalier on 4/21/19.
////  Copyright © 2019 Jonathan Parham. All rights reserved.
////
//
//import SpriteKit
//
//class OldBase: SKSpriteNode{
//
//    var money = 0
////    var tiles = Set<Int>()
//    var baseIndex:Int
//    var soldiers = Set<Soldier>()
//    var isValid : Bool
//
//    init( _ index: Int){
//        self.baseIndex = index
//        self.isValid = true
//        super.init(texture: Base.baseTextures[0], color: UIColor.clear,size: CGSize(width:8,height:8))
//        update()
//        randomizeBase()
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    static func == (lhs: Base, rhs: Base) -> Bool {
//        return lhs.baseIndex == rhs.baseIndex
//    }
//
//
//
//
//    static var grid : [Int] = []
//    static var visitedGrid : [Bool] = []
//    static var gridSize = 0
//    static var gridWidth = 0
//    static var gridHeight = 0
//    static var bases : [Base] = []
//
//    static var baseTextures : [SKTexture] = []
//    static var reverseTextures : [SKTexture] = []
//    static var map : SKTileMapNode!
//
//    static func load(_ map: SKTileMapNode){
//        self.map = map
//        gridWidth = map.numberOfColumns
//        gridHeight = map.numberOfRows
//        gridSize = gridWidth*gridHeight
//        grid = [Int](repeating: -1, count: gridSize)
//        visitedGrid = [Bool](repeating: false, count: gridSize)
//
//        for i in 0..<4{
//            baseTextures.append(SKTexture(imageNamed: "chest\(i)SNG_0.png"))
//            reverseTextures.append(SKTexture(imageNamed: "chest\(3-i)SNG_0.png"))
//        }
//    }
//
//    static func resetVisitedGrid(){
//        for i in 0..<gridSize{
//            visitedGrid[i] = false
//        }
//    }
//
//    static func getIndex(_ x: Int, _ y: Int) -> Int{
//        return x + y*gridWidth
////        return x + (gridHeight-y-1)*gridWidth
//
//    }
//
//    static func getCoord(_ index: Int) -> (Int,Int){
//        return (index%gridWidth,index/gridWidth)
////        return (index%gridWidth,gridHeight - index/gridWidth - 1)
//    }
//
//    static func setTileOwner(_ owner: Int, _ x: Int, _ y: Int){
//        grid[getIndex(x, y)] = owner
//    }
//
//    static func getTileOwner(_ x: Int, _ y : Int) -> Int{
//        return grid[getIndex(x,y)]
//    }
//
//    static func addNewBases(){
//        mainLoop: for i in 0..<gridSize{
//            checkNeedNewBase(i)
//        }
//    }
//
//    static func checkNeedNewBase(_ index: Int){
//        for base in bases{
//            if base.contains(index){
//                return
//            }
//        }
//        let base = Base(index)
//        if base.isValid{
//            bases.append(base)
//            map.addChild(base)
//        }
//    }
//
//    static func getBase(_ index: Int) -> Base?{
//        for base in bases{
//            if base.contains(index){
//                return base
//            }
//        }
//        return nil
//    }
//
//    static func getBase(_ x: Int, _ y: Int) -> Base?{
//        return getBase(getIndex(x,  y))
//    }
//
//    static func getNearByBase(_ num: Int, _ index: Int) -> Base?{
//        var base : Base? = nil
//        for dx in -1...1{
//            for dy in -1...1{
//                if (dx == 0 || dy == 0) && dx != dy{
//                    if let newBase = getBase(index+dx+dy*gridWidth),grid[newBase.baseIndex] == num{
//                        if let b = base, b.baseIndex != newBase.baseIndex{
//                            newBase.removeSelf()
//                        }else{
//                            base = newBase
//                        }
//                    }
//                }
//            }
//        }
//        return base
//    }
//
//    static func expandBase(_ num: Int, _ x: Int, _ y: Int) -> Bool{
//        print("Expanding Base: ",num,"X:",x,"Y:",y)
//        let index = Base.getIndex(x, y)
//        if grid[index] == num{
//            return false
//        }
//        if let base = getNearByBase(num, index){
//            if let enemyBase = Base.getBase(x, y){
//                base.attackTile(enemyBase, index)
//            }else{
//                grid[index] = num
//            }
//            print("Adding all new Tiles")
//            let _ = base.update()
//            return true
//        }else{
//            print("No nearby bases")
//        }
//        return false
//    }
//
//    static func payDay(){
//        for base in bases{
//            base.money += base.count()
//        }
//    }
//    static func printGrid(){
//        print("Grid: \(gridWidth)x\(gridHeight)")
//        var line = ""
//        for i in 0..<gridSize{
//            line += grid[i] == -1 ? "  " : "\(grid[i]) "
//            if i % gridWidth == 0{
//                print(line)
//                line = ""
//            }
//        }
//        print("--")
//    }
//
//    static func printBases(){
//        print("Bases: \(bases.count)")
//        for base in bases{
//            var line = "\(base.baseIndex):"
//            for tile in base.tiles{
//                line += " \(tile)"
//            }
//            print(line)
//        }
//    }
//
//
//    func update(){
//        Base.resetVisitedGrid()
//        tiles = Set<Int>()
//        updateSearch(baseIndex)
//        if count() < 2{
//            removeSelf()
//        }
//    }
//
//
//    func updateSearch(_ index: Int){
//        if index < 0 || index >= Base.gridSize || Base.visitedGrid[index]{
//            return
//        }
//        Base.visitedGrid[index] = true;
//        if Base.grid[index] == Base.grid[baseIndex]{
//            for base in Base.bases{
//                if base.baseIndex != baseIndex && base.contains(index){
//                    base.removeSelf();
//                }
//            }
//            tiles.insert(index)
//            updateSearch(index-1)
//            updateSearch(index+1)
//            updateSearch(index-Base.gridWidth)
//            updateSearch(index+Base.gridWidth)
//        }
//    }
//
//    func removeSelf(){
//        isValid = false
//        if let arrIndex = Base.bases.firstIndex(of:self){
//            Base.bases.remove(at:arrIndex)
//            removeFromParent()
//        }
//    }
//
//    func randomizeBase(){
//        if isValid, let baseTile = tiles.randomElement(){
//            baseIndex = baseTile
//        }
//        let (x,y) = Base.getCoord(baseIndex)
//        position = Base.map.centerOfTile(atColumn: x, row: y)
//    }
//
//    func contains(_ index: Int) -> Bool{
//        return tiles.contains(index)
//    }
//
//    func count()-> Int{
//        return tiles.count
//    }
//
//    func attackTile(_ other: Base, _ enemyIndex: Int){
//        print("ATTACK")
//        other.tiles.remove(enemyIndex)
//        if other.baseIndex == enemyIndex{//attacked the base tile
//            money += other.money/2
//            other.money = 0
//            other.randomizeBase()
//        }
//        Base.grid[enemyIndex] = Base.grid[baseIndex]
//        let prevTiles = other.tiles
//        other.update()
//        for index in prevTiles{
//            Base.checkNeedNewBase(index)
//        }
//        tiles.insert(enemyIndex)
//    }
//
//
//
//    func animate(open: Bool){
//        let animate = SKAction.animate(with: open ? Base.baseTextures : Base.reverseTextures, timePerFrame: 0.1)
//        self.run(animate)
//    }
//
//}
