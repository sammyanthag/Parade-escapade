//
//  GameScene.swift
//  parade-escapade
//
//  Created by Nicholas Crawford on 1/12/16.
//  Copyright (c) 2016 Nick Crawford. All rights reserved.
//

import SpriteKit


//Override operators for CGPoints
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * scalar.x, y: point.y * scalar.y)
}

func / (point: CGPoint, scalar: CGPoint) -> CGPoint {
    return CGPoint(x: point.x / scalar.x, y: point.y / scalar.y)
}

func distance(p1:CGPoint, p2:CGPoint) -> CGFloat {
    return CGFloat(hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y)))
}

func round(point:CGPoint) -> CGPoint {
    return CGPoint(x: round(point.x), y: round(point.y))
}

func floor(point:CGPoint) -> CGPoint {
    return CGPoint(x: floor(point.x), y: floor(point.y))
}

func ceil(point:CGPoint) -> CGPoint {
    return CGPoint(x: ceil(point.x), y: ceil(point.y))
}

//Declare Tile Enum
enum Direction: Int {
    
    case N,NE,E,SE,S,SW,W,NW
    
    var description:String {
        switch self {
        case N:return "North"
        case NE:return "North East"
        case E:return "East"
        case SE:return "South East"
        case S:return "South"
        case SW:return "South West"
        case W:return "West"
        case NW:return "North West"
        }
    }
}

enum Tile: Int {
    
    case Ground, Wall, Droid
    
    var description:String {
        switch self {
        case Ground:return "Ground"
        case Wall:return "Wall"
        case Droid:return "Droid"
        }
    }
}

enum Action: Int {
    case Idle, Move
    
    var description:String {
        switch self {
        case Idle:return "Idle"
        case Move:return "Move"
        }
    }
}

class GameScene: SKScene {
    
    //1
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //2
    let view2D:SKSpriteNode
    let viewIso:SKSpriteNode
    
    //Setup layers
    let layerIsoGround:SKNode
    let layerIsoObjects:SKNode
    
    //3
    var tiles:[[(Int, Int)]]
    let tileSize = (width:32, height:32)
    
    //Initializa Hero
    let hero = Droid()
    
    //Set frames for depth sorting optimization
    let nthFrame = 6
    var nthFrameCount = 0
    
    //4
    override init(size: CGSize) {
        //Initialize tiles
        tiles =     [[(1,7), (1,0), (1,0), (1,0), (1,0), (1,0), (1,0), (1,0), (1,1)]]
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (0,0), (0,0), (0,0), (1,2)])
        tiles.append([(1,6), (0,0), (2,2), (0,0), (0,0), (0,0), (0,0), (0,0), (1,2)])
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (1,5), (1,4), (1,4), (1,5)])
        tiles.append([(1,6), (0,0), (0,0), (1,7), (0,0), (0,0), (0,0), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (1,6), (0,0), (0,0), (0,0), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (1,5), (1,4), (1,4), (1,1), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (0,0), (1,2), (0,0), (0,0)])
        tiles.append([(1,6), (0,0), (0,0), (0,0), (0,0), (0,0), (1,3), (0,0), (0,0)])
        tiles.append([(1,5), (1,4), (1,4), (1,3), (0,0), (0,0), (0,0), (0,0), (0,0)])
        
        view2D = SKSpriteNode()
        viewIso = SKSpriteNode()
        
        layerIsoGround = SKNode()
        layerIsoObjects = SKNode()
        
        super.init(size: size)
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
    }
    
    //5
    override func didMoveToView(view: SKView) {
        
        let deviceScale = self.size.width/667
        
        view2D.position = CGPoint(x:-self.size.width*0.48, y:self.size.height*0.43)
        let view2DScale = CGFloat(0.4)
        view2D.xScale = deviceScale * view2DScale
        view2D.yScale = deviceScale * view2DScale
        addChild(view2D)
        
        viewIso.position = CGPoint(x:self.size.width*0, y:self.size.height*0.25)
        viewIso.xScale = deviceScale
        viewIso.yScale = deviceScale
        
        viewIso.addChild(layerIsoGround)
        viewIso.addChild(layerIsoObjects)
        addChild(viewIso)
        
        placeAllTiles2D()
        placeAllTilesIso()
    }
    
    func placeTile2D(tile:Tile, direction:Direction, position:CGPoint) {
        
        let tileSprite = SKSpriteNode(imageNamed: textureImage(tile, direction, Action.Idle))
        
        if (tile == hero.tile) {
            hero.tileSprite2D = tileSprite
            hero.tileSprite2D.zPosition = 1
        }
        
        tileSprite.position = position
        
        tileSprite.anchorPoint = CGPoint(x:0, y:0)
        
        view2D.addChild(tileSprite)
        
    }
    
    //Place tiles in 2d view
    func placeAllTiles2D() {
        
        for i in 0..<tiles.count {
            
            let row = tiles[i];
            
            for j in 0..<row.count {
                
                let tile = Tile(rawValue: row[j].0)!
                let direction = Direction(rawValue: row[j].1)!
                
                var point = CGPoint(x: (j*tileSize.width), y: -(i*tileSize.height))
                
                if (tile == Tile.Droid) {
                    placeTile2D(Tile.Ground, direction:direction, position:point)
                }
                
                placeTile2D(tile, direction:direction, position:point)
            }
            
        }
    }
    
    //Place tiles in iso view
    func placeTileIso(tile:Tile, direction:Direction, position:CGPoint) {
        
        let tileSprite = SKSpriteNode(imageNamed: "iso_3d_"+textureImage(tile, direction, Action.Idle))
        
        if (tile == hero.tile) {
            hero.tileSpriteIso = tileSprite
        }
        
        tileSprite.position = position
        
        tileSprite.anchorPoint = CGPoint(x:0, y:0)
        
        if (tile == Tile.Ground) {
            layerIsoGround.addChild(tileSprite)
        } else if (tile == Tile.Wall || tile == Tile.Droid) {
            layerIsoObjects.addChild(tileSprite)
        }
        
    }
    func placeAllTilesIso() {
        
        for i in 0..<tiles.count {
            
            let row = tiles[i];
            
            for j in 0..<row.count {
                
                let tile = Tile(rawValue: row[j].0)!
                let direction = Direction(rawValue: row[j].1)!
                
                var point = point2DToIso(CGPoint(x: (j*tileSize.width), y: -(i*tileSize.height)))
                
                if (tile == Tile.Droid) {
                    placeTileIso(Tile.Ground, direction:direction, position:point)
                }
                
                placeTileIso(tile, direction:direction, position:point)
                
            }
        }
    }
    
    //Functions for converting Iso to 2d points vice versa.
    func point2DToIso(p:CGPoint) -> CGPoint {
        
        //invert y pre conversion
        var point = p * CGPoint(x:1, y:-1)
        
        //convert using algorithm
        point = CGPoint(x:(point.x - point.y), y: ((point.x + point.y) / 2))
        
        //invert y post conversion
        point = point * CGPoint(x:1, y:-1)
        
        return point
        
    }
    func pointIsoTo2D(p:CGPoint) -> CGPoint {
        
        //invert y pre conversion
        var point = p * CGPoint(x:1, y:-1)
        
        //convert using algorithm
        point = CGPoint(x:((2 * point.y + point.x) / 2), y: ((2 * point.y - point.x) / 2))
        
        //invert y post conversion
        point = point * CGPoint(x:1, y:-1)
        
        return point
        
    }
    //Converting coordinates to tile indices
    func point2DToPointTileIndex(point:CGPoint) -> CGPoint {
        
        return floor(point / CGPoint(x: tileSize.width, y: tileSize.height))
        
    }
    func pointTileIndexToPoint2D(point:CGPoint) -> CGPoint {
        
        return point * CGPoint(x: tileSize.width, y: tileSize.height)
        
    }
    
    func degreesToDirection(var degrees:CGFloat) -> Direction {
        
        if (degrees < 0) {
            degrees = degrees + 360
        }
        let directionRange = 45.0
        
        degrees = degrees + CGFloat(directionRange/2)
        
        var direction = Int(floor(Double(degrees)/directionRange))
        
        if (direction == 8) {
            direction = 0
        }
        
        return Direction(rawValue: direction)!
    }
    
    func sortDepth() {
        
        //1
        let childrenSortedForDepth = layerIsoObjects.children.sort() {
            
            let p0 = self.pointIsoTo2D($0.position)
            let p1 = self.pointIsoTo2D($1.position)
            
            if ((p0.x+(-p0.y)) > (p1.x+(-p1.y))) {
                return false
            } else {
                return true
            }
            
        }
        //2
        for i in 0..<childrenSortedForDepth.count {
            
            let node = (childrenSortedForDepth[i] as! SKNode)
            
            node.zPosition = CGFloat(i)
            
        }
    }
    
    //Function for A* Traversing
    func traversableTiles() -> [[Int]] {
        
        //1
        var tTiles = [[Int]]()
        
        //2
        func binarize(num:Int) ->Int {
            if (num == 1) {
                return Global.tilePath.nonTraversable
            } else {
                return Global.tilePath.traversable
            }
        }
        
        //3
        for i in 0..<tiles.count {
            let tt = tiles[i].map{i in binarize(i.0)}
            tTiles.append(tt)
        }
        
        return tTiles
    }
    
    func findPathFrom(from:CGPoint, to:CGPoint) -> [CGPoint]? {
        
        let traversable = traversableTiles()
        
        //1
        if (Int(to.x) > 0)
            && (Int(to.x) < traversable.count)
            && (Int(-to.y) > 0)
            && (Int(-to.y) < traversable.count)
        {
            
            //2
            if (traversable[Int(-to.y)][Int(to.x)] == Global.tilePath.traversable ) {
                
                //3
                let pathFinder = PathFinder(xIni: Int(from.x), yIni: Int(from.y), xFin: Int(to.x), yFin: Int(to.y), lvlData: traversable)
                let myPath = pathFinder.findPath()
                return myPath
                
            } else {
                
                return nil
            }
            
        } else {
            
            return nil
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //////////////////////////////////////////////////////////
        // Original code that we still need
        //////////////////////////////////////////////////////////
        
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(viewIso)
        
        var touchPos2D = pointIsoTo2D(touchLocation)
        
        touchPos2D = touchPos2D + CGPoint(x:tileSize.width/2, y:-tileSize.height/2)
        
        //////////////////////////////////////////////////////////
        // PathFinding code that replaces our old positioning code
        //////////////////////////////////////////////////////////
        
        //1
        let path = findPathFrom(point2DToPointTileIndex(hero.tileSprite2D.position), to: point2DToPointTileIndex(touchPos2D))
        
        if (path != nil) {
            
            //2
            var newHeroPos2D = CGPoint()
            var prevHeroPos2D = hero.tileSprite2D.position
            var actions = [SKAction]()
            
            //3
            for i in 1..<path!.count {
                
                //4
                newHeroPos2D = pointTileIndexToPoint2D(path![i])
                let deltaY = newHeroPos2D.y - prevHeroPos2D.y
                let deltaX = newHeroPos2D.x - prevHeroPos2D.x
                let degrees = atan2(deltaX, deltaY) * (180.0 / CGFloat(M_PI))
                actions.append(SKAction.runBlock({
                    self.hero.facing = self.degreesToDirection(degrees)
                    self.hero.update()
                }))
                
                //5
                let velocity:Double = Double(tileSize.width)*5
                var time = 0.0
                
                if i == 1 {
                    
                    //6
                    time = NSTimeInterval(distance(newHeroPos2D, p2: hero.tileSprite2D.position)/CGFloat(velocity))
                    
                } else {
                    
                    //7
                    let baseDuration =  Double(tileSize.width)/velocity
                    var multiplier = 1.0
                    
                    let direction = degreesToDirection(degrees)
                    
                    if direction == Direction.NE
                        || direction == Direction.NW
                        || direction == Direction.SW
                        || direction == Direction.SE
                    {
                        //8
                        multiplier = 1.4
                    }
                    
                    //9
                    time = multiplier*baseDuration
                }
                
                //10
                actions.append(SKAction.moveTo(newHeroPos2D, duration: time))
                
                //11
                prevHeroPos2D = newHeroPos2D
                
            }
            
            //12
            hero.tileSprite2D.removeAllActions()
            hero.tileSprite2D.runAction(SKAction.sequence(actions))
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        hero.tileSpriteIso.position = point2DToIso(hero.tileSprite2D.position)
        
        //Sort Depth every nth frame
        nthFrameCount += 1
        if (nthFrameCount == nthFrame) {
            nthFrameCount = 0
            updateOnNthFrame()
        }
    }
    
    func updateOnNthFrame() {
        sortDepth()
    }
    
}