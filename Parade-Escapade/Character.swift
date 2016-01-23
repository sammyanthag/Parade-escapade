import UIKit
import SpriteKit

//1
protocol TileObject {
    var tile:Tile {get}
}

//2
class Character {
    
    var facing:Direction
    var action:Action
    
    var tileSpriteIso:SKSpriteNode!
    
    init() {
        facing = Direction.E
        action = Action.Idle
    }
    
}

//3
class DrumMajor:Character, TileObject {
    
    let tile = Tile.DrumMajor
    
    func update() {
        
        if (self.tileSpriteIso != nil) {
            
            self.tileSpriteIso.texture = TextureDrumMajor.sharedInstance.texturesIso[self.action.rawValue]![self.facing.rawValue]
            
        }
    }
}