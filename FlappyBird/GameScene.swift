//
//  GameScene.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bird = SKSpriteNode()
    var skyColor = SKColor()
    var verticalPipeGap = 150.0
    var pipeTextureUp = SKTexture()
    var pipeTextureDown = SKTexture()
    var movePipesAndRemove = SKAction()
    let birdBitMaskCategory: UInt32 = 0x1 << 0;
    let pipeBitMaskCategory: UInt32 = 0x1 << 1;
    
    override func didMoveToView(view: SKView) {
        // setup physics
        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 )

        // setup contact delegate
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        // ground
        var groundTexture = SKTexture(imageNamed: "land")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        var moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.02 * groundTexture.size().width * 2.0))
        var resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        var moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 2.0 ); ++i {
            var sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpritesForever)
            self.addChild(sprite)
        }
        
        // skyline
        var skyTexture = SKTexture(imageNamed: "sky")
        skyTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        var moveSkySprite = SKAction.moveByX(-skyTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.1 * skyTexture.size().width * 2.0))
        var resetSkySprite = SKAction.moveByX(skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        var moveSkySpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( skyTexture.size().width * 2.0 ); ++i {
            var sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20;
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            sprite.runAction(moveSkySpritesForever)
            self.addChild(sprite)
        }
        
        // create the pipes textures
        pipeTextureUp = SKTexture(imageNamed: "PipeUp")
        pipeTextureUp.filteringMode = SKTextureFilteringMode.Nearest
        pipeTextureDown = SKTexture(imageNamed: "PipeDown")
        pipeTextureDown.filteringMode = SKTextureFilteringMode.Nearest
        
        // create the pipes movement actions
        var distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeTextureUp.size().width);
        var movePipes = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove));
        var removePipes = SKAction.removeFromParent();
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes]);
        
        // spawn the pipes
        var spawn = SKAction.runBlock({() in self.spawnPipes()})
        var delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        var spawnThenDelay = SKAction.sequence([spawn, delay])
        var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        // setup our bird
        var birdTexture1 = SKTexture(imageNamed: "bird-01")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        var birdTexture2 = SKTexture(imageNamed: "bird-02")
        birdTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        var anim = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2)
        var flap = SKAction.repeatActionForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        bird.runAction(flap)
        
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody.dynamic = true
        bird.physicsBody.allowsRotation = false
        
        self.addChild(bird)
        
        // create the ground
        var ground = SKNode()
        ground.position = CGPointMake(0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2.0))
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }
    
    func spawnPipes() {
        var pipePair = SKNode()
        pipePair.position = CGPointMake( self.frame.size.width + pipeTextureUp.size().width * 2, 0 );
        pipePair.zPosition = -10;
        
        var height = UInt32( self.frame.size.height / 4 )
        var y = arc4random() % height + height;
        
        var pipeDown = SKSpriteNode(texture: pipeTextureDown)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(verticalPipeGap))
        
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody.dynamic = false
        pipeDown.physicsBody.categoryBitMask = pipeBitMaskCategory
        pipePair.addChild(pipeDown)
        
        var pipeUp = SKSpriteNode(texture: pipeTextureUp)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody.dynamic = false
        pipeUp.physicsBody.categoryBitMask = pipeBitMaskCategory
        pipePair.addChild(pipeUp)
        
        pipePair.runAction(movePipesAndRemove);
        self.addChild(pipePair)
    }
    
    func emitParticles() {
        var burstEmitter = SKEmitterNode()
        burstEmitter.position = bird.position
        burstEmitter.particleBirthRate = 160
        burstEmitter.numParticlesToEmit = 40
        burstEmitter.particleLifetime = 0.6
        burstEmitter.particleLifetimeRange = 0
        burstEmitter.emissionAngle = 77.7
        burstEmitter.emissionAngleRange = 360
        burstEmitter.particleSpeed = 120
        burstEmitter.particleSpeedRange = 60
        burstEmitter.particleAlpha = 1
        burstEmitter.particleAlphaRange = 0
        burstEmitter.particleRotation = 0
        burstEmitter.particleRotationRange = 360
        burstEmitter.particleRotationSpeed = 1.14
        burstEmitter.particleColor = UIColor.redColor()
        burstEmitter.particleSize = CGSize(width: 25, height: 25)
        burstEmitter.particleScale = 0.5
        burstEmitter.particleScaleRange = 1.0
        
        self.addChild(burstEmitter)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            bird.physicsBody.velocity = CGVectorMake(0, 0)
            bird.physicsBody.applyImpulse(CGVectorMake(0, 30))
            bird.physicsBody.categoryBitMask = birdBitMaskCategory
            bird.physicsBody.usesPreciseCollisionDetection = true
            bird.physicsBody.collisionBitMask = birdBitMaskCategory | pipeBitMaskCategory
            bird.physicsBody.contactTestBitMask = birdBitMaskCategory | pipeBitMaskCategory
        }
    }
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max;
        } else if( value < min ) {
            return min;
        } else {
            return value;
        }
    }
    
    // implement the SKPhysicsContactDelegate method to handle contact
    func didBeginContact(contact: SKPhysicsContact) {
        // bodyA is our pipe, destroy it!
        var pipe = contact.bodyA as SKPhysicsBody
        pipe.node.removeFromParent()
        
        // Add the particles here
        self.emitParticles()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        bird.zRotation = self.clamp( -1, max: 0.5, value: bird.physicsBody.velocity.dy * ( bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    }
}
