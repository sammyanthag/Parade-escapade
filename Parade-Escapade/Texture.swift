import UIKit
import SpriteKit

func textureImage(tile:Tile, _ direction:Direction, _ action:Action) -> String {
    
    switch tile {
    case .DrumMajor:
        switch action {
        case .Idle:
            switch direction {
            case .N:return " drummajor_n"
            case .E:return " drummajor_e"
            case .S:return " drummajor_s"
            case .W:return " drummajor_w"
            }
        case .Move:
            switch direction {
            case .N:return " drummajor_n"
            case .E:return " drummajor_e"
            case .S:return " drummajor_s"
            case .W:return " drummajor_w"
            }
        }
    case .Road:
        return "road"
    case .Wall:
        return "wall"
    }
    
}

protocol TextureObject {
    static var sharedInstance: TextureDrumMajor {get}
    var texturesIso:[[SKTexture]?] {get}
}

private let textureDrumMajor = TextureDrumMajor()

class TextureDrumMajor: TextureObject  {
    
    class var sharedInstance: TextureDrumMajor {
        return textureDrumMajor
    }
    
    var texturesIso:[[SKTexture]?]
    
    init() {
        
        texturesIso = [[SKTexture]?](count: 2, repeatedValue: nil)
        
        //Idle
        texturesIso[Action.Idle.rawValue] = [
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.N, Action.Idle)),
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.E, Action.Idle)),
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.S, Action.Idle)),
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.W, Action.Idle)),
        ]
        
        //Move
        texturesIso[Action.Move.rawValue] = [
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.N, Action.Move)),
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.E, Action.Move)),
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.S, Action.Move)),
            SKTexture(imageNamed:  textureImage(Tile.DrumMajor, Direction.W, Action.Move)),
        ]
        
    }
    
}