//
//  Logic.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/24/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import Foundation

class Piece{
    var playerId : Int
    var UID: Int
    var rank = -2
    
    static let maxPlayerId = 3
    static var counterUID = 0
    
    init(_ playerId: Int){
        self.playerId = playerId
        self.UID = Piece.counterUID
        Piece.counterUID += 1
    }
    
    func copy() -> Piece{
        let piece = Piece(playerId)
        piece.UID = UID
        return piece
    }
    
    func isBase() -> Bool{
        return rank == -1
    }
    
    func isSoldier() -> Bool{
        return rank >= 0
    }
    
    func isEmpty() -> Bool{
        return rank < -1
    }
    
}
