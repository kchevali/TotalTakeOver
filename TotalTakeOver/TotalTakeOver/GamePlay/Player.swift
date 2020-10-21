//
//  Player.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/24/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import GameplayKit

class Player: NSObject, GKGameModelPlayer{
    var playerId: Int
    
    init(_ id: Int){
        playerId = id
    }

}
