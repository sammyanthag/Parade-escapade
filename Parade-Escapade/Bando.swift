//
//  Bando.swift
//  Parade-Escapade
//
//  Created by Nicholas Crawford on 1/23/16.
//  Copyright © 2016 UnimaginativeShits. All rights reserved.
//

import UIKit
import SpriteKit

class Bando:Character, TileObject {

    var tile = Tile.Flag
    var type = Instrument.Flag
    
    func setType(type:Instrument, tile:Tile) {
        self.type = type
        self.tile = tile
    }
    
    func update() {
        if (self.tileSpriteIso != nil) {
            
            self.tileSpriteIso.texture = TextureDrumMajor.sharedInstance.texturesIso[self.action.rawValue]![self.facing.rawValue]
            
        }
    }
}
