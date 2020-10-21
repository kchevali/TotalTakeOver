//
//  Bank.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/21/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import SpriteKit

class Base: Piece, Equatable{
    
    var isValid = true
    var money = 0
    var tiles : [(x:Int,y:Int)] = []
    var soldiers : [(x:Int,y:Int)] = []
    var visited = Set<Int>()
    
    
    override init(_ playerId: Int){
        super.init(playerId)
        self.rank = -1
    }
    
    func addTile(_ x: Int, _ y: Int){
        tiles.append((x:x,y:y))
    }
    
    func purchaseSoldier(_ x: Int, _ y: Int){
        soldiers.append((x:x,y:y))
        money -= Soldier.costs[0]
    }
    
    func canPurchase() -> Bool{
        return money >= Soldier.costs[0]
    }
    
    func moveSoldier(_ x0: Int, _ y0: Int, _ x: Int, _ y: Int){
        removeTile(x0, y0)
        soldiers.append((x:x,y:y))
    }
    
    func removeTile(_ x:Int,_ y:Int){
        for i in 0..<soldiers.count{
            let (x1,y1) = soldiers[i]
            if x == x1 && y == y1{
                soldiers.remove(at: i)
                return
            }
        }
    }
    
    func clear(){
        tiles = []
        soldiers = []
        visited = Set<Int>()
    }
    
    func visit(_ x: Int, _ y: Int){
        visited.insert(x+y*1000)
    }
    
    func hasVisited(_ x: Int, _ y: Int) -> Bool{
        return visited.contains(x+y*1000)
    }
    
    func attackBase(_ other: Base){
        money += other.money
    }
    
    func randomize() ->(x:Int,y:Int)?{
        if let tile = tiles.randomElement(){
            return tile
        }
        return nil
    }
    
    func takeTile(_ x: Int, y: Int){
        tiles.append((x:x,y:y))
    }
    
    override func copy() -> Piece{
        let base = Base(playerId)
        base.tiles = tiles
        base.visited = visited
        base.isValid = isValid
        base.soldiers = soldiers
        base.money = money
        base.UID = UID
        return base
    }
    
    static func == (lhs: Base, rhs: Base) -> Bool {
        return lhs.UID == rhs.UID
    }
}
