//
//  Move.swift
//  TileMaps
//
//  Created by Kevin Chevalier on 4/24/19.
//  Copyright © 2019 Jonathan Parham. All rights reserved.
//

import GameplayKit

class Move: NSObject, GKGameModelUpdate{
    var value: Int = 0
    var src: (x: Int, y: Int)
    var dest: (x: Int, y: Int)? = nil
    
    init(_ x0: Int,_ y0: Int,_ x: Int?,_ y: Int?){
        self.src = (x0,y0)
        if let x = x, let y = y{
            self.dest = (x,y)
        }
    }
}


