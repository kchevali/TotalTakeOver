//
//  Board.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/24/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import GameplayKit

class Board: NSObject, GKGameModel{
    var players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    var grid : [[Piece]] = []
    var bases : [(x:Int,y:Int)] = []
    
    static var width: Int!, height: Int!
    static var game: GameScene!
    static var validTiles: [[Bool]] = []
    static var boardsChecked = 0
    
    static func load(_ game: GameScene){
        Board.game = game
        Board.width = game.mapWidth
        Board.height = game.mapHeight
        Board.validTiles = Board.game.getValidTiles()
    }
    
    override init(){
        super.init()
        players = []
        for i in 1...Piece.maxPlayerId{
            players!.append(Player(i))
        }
        if let player = players!.randomElement(){
            activePlayer = player
            Board.game.isCPUTurn = player.playerId != Board.game.playerNum
        }
        for _ in 0..<Board.width{
            var row : [Piece] = []
            for _ in 0..<Board.height{
                row.append(Piece(-1))
            }
            grid.append(row)
        }
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board{
            for i in 0..<Board.width{
                for j in 0..<Board.height{
                    grid[i][j] = board.grid[i][j].copy()
                }
            }
            for base in board.bases{
                bases.append((x:base.x,y:base.y))
            }
            activePlayer = board.activePlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        if !isWin(for:player){
            var moves : [GKGameModelUpdate] = []
            for (baseX,baseY) in bases{
                if let base = grid[baseX][baseY] as? Base, base.playerId == player.playerId{
                    for src in base.tiles{
                        if canPurchase(base, src.x, src.y){
                            moves.append(Move(src.x,src.y,nil,nil))
                        }
                        for x in 0..<Board.width{
                            for y in 0..<Board.height{
                                if canMove(base,src, (x,y)){
                                    moves.append(Move(src.x,src.y,x,y))
                                }
                            }
                        }
                    }
                }
            }
            return moves
        }
        return nil

    }
    
    
    func updateBasesStart(_ player: GKGameModelPlayer){
        payBases(player)
    }
    
    func updateBasesEnd(_ player: GKGameModelPlayer){
        for (x,y) in bases{
            if let base = grid[x][y] as? Base, base.playerId == player.playerId{
                getTiles(base,x,y)
            }
        }
        removeDeadBases(player)
        removeDuplicateBases(player)
    }
    
    func removeDeadBases(_ player: GKGameModelPlayer){
        for (x,y) in bases{
            if let base = grid[x][y] as? Base, base.playerId == player.playerId{
                if base.tiles.count < 2{
                    for (soldierX,soldierY) in base.soldiers{
                        grid[soldierX][soldierY] = Piece(base.playerId)
                    }
                    grid[x][y] = Piece(base.playerId)
                    removeBase(base)
                    removeDeadBases(player)
                    return
                }
            }
        }
    }
    
    func removeDuplicateBases(_ player: GKGameModelPlayer){
        for baseA in bases{
            if let base = grid[baseA.x][baseA.y] as? Base, base.playerId == player.playerId{
                for baseB in bases{
                    if let other = grid[baseB.x][baseB.y] as? Base, base != other, base.playerId == player.playerId{
                        let tile = other.tiles[0]
                        if base.hasVisited(tile.x, tile.y){
                            grid[baseB.x][baseB.y] = Piece(base.playerId)
                            removeBase(other)
                            removeDuplicateBases(player)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func payBases(_ player: GKGameModelPlayer){
        for (x,y) in bases{
            if let base = grid[x][y] as? Base, base.playerId == player.playerId{
                base.money += base.tiles.count
                for (x2,y2) in base.soldiers{
                    if let soldier = grid[x2][y2] as? Soldier{
                        if soldier.isDead{
                            grid[x2][y2] = Piece(soldier.playerId)
                        }
                        if base.money >= soldier.pay(){
                            base.money -= soldier.pay()
                        }else{
                            soldier.die()
                        }
                    }else{
                        print("Cannot pay for non soldier")
                    }
                }
            }
        }
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
//        print("Applying move")
        if let move = gameModelUpdate as? Move{
            let src = move.src
            if let dest = move.dest{
                movePiece(src,dest)
            }else{
                newSoldier(src)
            }
        }else{
            print("Not a move")
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        Board.boardsChecked += 1
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    func resetBoard(){
        for x in 0..<Board.width{
            for y in 0..<Board.height{
                if Board.validTiles[x][y]{
                    let num = Int.random(in: 1...Piece.maxPlayerId)
                    grid[x][y] = Piece(num)
                    Board.game.setTile(num,x,y)
                }
            }
        }
        getBases()
    }
    
    func startTurn(){
        if let player = activePlayer{
//            print("Start: ", player.playerId)
            updateBasesStart(player)
//            Board.game.animateStartTurn(player.playerId)
            if Board.game.isCPUTurn{
                Board.game.executeAIMove()
//                print("CPU END: ", player.playerId)

                endTurn()
            }else{
                print("Boards Checked:",Board.boardsChecked)
                Board.boardsChecked = 0
            }
        }
    }
    
    func endTurn(){
        
        if let player = activePlayer, let players = players{
            updateBasesEnd(player)
            activePlayer = players[player.playerId >= players.count ? 0 : player.playerId]
            Board.game.isCPUTurn = activePlayer!.playerId != Board.game.playerNum
            Board.game.updateGraphics()
            
            if isWin(for: players[Board.game.playerNum]){
                Board.game.createAlert("You Win!", "You have defeated all of the enemies", "Play Again!")
            }
            if isLoss(for: players[Board.game.playerNum]){
                Board.game.createAlert("You Lose!", "All of your bases were destroyed!", "Play Again:(")
            }

        }
        startTurn()
    }
    
    func emptyTile(_ playerId: Int, _ x: Int, _ y: Int){
        grid[x][y] = Piece(playerId)
    }
    
    func join(_ baseA: Base, _ a : (x:Int,y:Int), _ b : (x:Int,y:Int)){
        if let soldierA = grid[a.x][a.y] as? Soldier,
            let soldierB = grid[b.x][b.y] as? Soldier{
            
            emptyTile(soldierA.playerId, a.x,a.y)
            if baseA.hasVisited(b.x,b.y){
                soldierB.upgrade()
            }else if let baseB = findBase(b.x, b.y){
                grid[b.x][b.y] = soldierA
                baseB.removeTile(b.x, b.y)
            }
        }

    }
    
    func checkHasBase(_ x: Int, _ y: Int){
        if x < 0 || y < 0 || x >= Board.width || y >= Board.height{
            return
        }
        if let base = findBase(x, y){
            getTiles(base, x, y)
            if base.tiles.count > 1{
                return
            }
        }
        newBase(x, y)
    }
    
    func movePiece(_ a:(x: Int, y: Int), _ b:(x: Int, y: Int)){
        if let soldierA = grid[a.x][a.y] as? Soldier{//Soldier is moving from an old location
//            print("Soldier had previous valid location")
            let tileB = grid[b.x][b.y]
            if let baseA = findBase(a.x, a.y){
                if tileB.isSoldier(){
                    join(baseA,a,b)
                }else{
                    if let baseB = tileB as? Base{
                        baseA.attackBase(baseB)
                        baseB.removeTile(b.x, b.y)
                        removeBase(baseB)
                        if let newB = baseB.randomize(){
                            newBase(newB.x,newB.y)
                        }
                        
                    }
                    grid[b.x][b.y] = soldierA
                    checkHasBase(b.x+1, b.y)
                    checkHasBase(b.x-1, b.y)
                    checkHasBase(b.x, b.y+1)
                    checkHasBase(b.x, b.y-1)
                    getTiles(baseA, a.x, a.y)
                }
                emptyTile(soldierA.playerId, a.x,a.y)
            }else{
                print("Base not found during move piece():",a.x,a.y,b.x,b.y)
            }
        }else{
            print("soldier not found during move piece()")
        }
    }
    
    func newSoldier(_ a:(x:Int,y:Int)){
        if let baseA = findBase(a.x, a.y){
            grid[a.x][a.y] = Soldier(baseA.playerId)
            baseA.purchaseSoldier(a.x, a.y)
        }else{
            print("Purchase failed: no base there")
        }
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool{
        for i in 0..<Board.width-1{
            for j in 0..<Board.height-1{
                let tile = grid[i][j]
                if tile.playerId != player.playerId && (tile.playerId == grid[i+1][j].playerId || tile.playerId == grid[i][j+1].playerId){
                    return false
                }
            }
        }
        return true
    }
    
    func isLoss(for player: GKGameModelPlayer) -> Bool{
        for i in 0..<Board.width-1{
            for j in 0..<Board.height-1{
                let tile = grid[i][j]
                if tile.playerId == player.playerId && (tile.playerId == grid[i+1][j].playerId || tile.playerId == grid[i][j+1].playerId){
                    return false
                }
            }
        }
        return true
    }
    
    
    func score(for player: GKGameModelPlayer) -> Int{
        if isWin(for: player){
            return 10000
        }
        if let enemies = players{
            for enemy in enemies{
                if isWin(for:enemy){
                    return -10000
                }
            }
        }
        var score = 0
        for base in bases{
            if let base = grid[base.x][base.y] as? Base, base.playerId == player.playerId{
                score += base.money + base.tiles.count*10 + base.soldiers.count*20
            }
        }
        return score
    }
    
    func canPurchase(_ baseA: Base, _ x: Int, _ y: Int) -> Bool{
        return baseA.canPurchase() && baseA.hasVisited(x, y) && !(grid[x][y] is Base) && !(grid[x][y] is Soldier)
    }
    
    func canMove(_ baseA: Base, _ a: (x: Int, y: Int), _ b:(x: Int, y: Int)) -> Bool{
        if a.x == b.x && a.y == b.y{
            return false
        }
        if !Board.validTiles[a.x][a.y] || !Board.validTiles[b.x][b.y]{
            return false
        }
        let tileA = grid[a.x][a.y]
        
        if !tileA.isSoldier(){
            return false
        }
        
        let tileB = grid[b.x][b.y]
        if tileB is Base && tileB.playerId == baseA.playerId{
//            print("CanMove(): False - destination is your base")
            return false
        }
        
        if let soldierA = tileA as? Soldier, soldierA.canUpgrade(baseA) && baseA.hasVisited(b.x, b.y) && tileA.rank == tileB.rank{
//            print("CanMove(): True - upgrading soldier")
            return true
        }
        
        if baseA.hasVisited(b.x, b.y) && tileB.isEmpty(){
//            print("CanMove(): True - empty tile")
            return true
        }
                
        if tileA.playerId != tileB.playerId && tileA.rank > tileB.rank &&
                (baseA.hasVisited(b.x+1, b.y) || baseA.hasVisited(b.x-1, b.y) || baseA.hasVisited(b.x, b.y+1) || baseA.hasVisited(b.x, b.y-1)){
//            print("CanMove(): True - attacking enemy soldier with nearby space")
            return true
        }
//        print("CanMove(): False - not upgrade nor enemy attack")
        return false
    }
    
    //BASE
    
    func newBase(_ x: Int, _ y: Int){
        let base = Base(grid[x][y].playerId)
        getTiles(base, x, y)
        if base.tiles.count > 1,let pos = base.randomize(){
            bases.append(pos)
            grid[pos.x][pos.y] = base
        }else{
            grid[x][y] = Piece(grid[x][y].playerId)
        }
    }
    
    func getBases(){
        let base = Base(-2)
        bases = []
        for x in 0..<Board.width{
            for y in 0..<Board.height{
                if Board.validTiles[x][y] && !base.hasVisited(x,y){
                    getTileSearch(base, x, y, x, y)
                    if let rand = base.tiles.randomElement(){
                        newBase(rand.x,rand.y)
                    }
                    base.tiles = []
                }else{
//                    print("VIS")
                }
            }
        }
    }

    func findBase(_ x: Int, _ y: Int) -> Base?{
        for (baseX,baseY) in bases{
            if let base = grid[baseX][baseY] as? Base, base.hasVisited(x,y){
                return base
            }
        }
        return nil
    }
    
    func removeBase(_ base: Base){
        for i in 0..<bases.count{
            let (x,y) = bases[i]
            if grid[x][y].UID == base.UID{
                bases.remove(at: i)
            }
            return
        }
    }
    
    func getTiles(_ base: Base, _ x: Int, _ y: Int){
        base.clear()
        getTileSearch(base, x, y,x,y)
    }
    
    func getTileSearch(_ base: Base, _ x0: Int, _ y0: Int, _ x: Int, _ y: Int){
        if x < 0 || x >= Board.width || y < 0 || y >= Board.height || base.hasVisited(x,y){
            return
        }
        if grid[x0][y0].playerId == grid[x][y].playerId{
//            print("Source:",grid[x0][y0].playerId, x, y)

            base.visit(x, y)
            base.addTile(x, y)
            if grid[x][y].isSoldier(){
                base.soldiers.append((x,y))
            }
            getTileSearch(base,x0,y0,x+1,y)
            getTileSearch(base,x0,y0,x-1,y)
            getTileSearch(base,x0,y0,x,y+1)
            getTileSearch(base,x0,y0,x,y-1)
        }
    }
    
    func printThis(){
        print("START")
        for x in 0..<Board.width{
            for y in 0..<Board.height{
                if grid[x][y].playerId != -1{
                    print(grid[x][y].playerId,terminator:" ")
                }
            }
            print()
        }
    }
    
    
    
    
}
