//
//  Soldier.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/21/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import SpriteKit

class Soldier: Piece, Equatable{
    
    static let costs = [5,7,15,25]
    static let pay = [2,5,7,10]
    static var counter = 0
    static var startRank = 1
    
    var isDead = false
    
    override init(_ playerId: Int) {
        super.init(playerId)
        self.rank = Soldier.startRank
    }
    
    func cost() -> Int{
        return Soldier.costs[rank]
    }
    func pay() -> Int{
        return Soldier.pay[rank]
    }
    func canUpgrade(_ base: Base)->Bool{
        return (rank+1) < Soldier.costs.count && base.money >= Soldier.costs[rank+1]
    }
    func upgrade(){
        rank += 1
    }
    func die(){
        isDead = true
    }
    
    override func copy() -> Piece{
        let soldier = Soldier(playerId)
        soldier.isDead = isDead
        soldier.UID = UID
        soldier.rank = rank
        return soldier
    }
    
    static func == (lhs: Soldier, rhs: Soldier) -> Bool {
        return lhs.UID == rhs.UID
    }
    
}
