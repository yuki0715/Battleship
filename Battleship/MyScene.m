//
//  MyScene.m
//  Battleship
//
//  Created by Rayyan Khoury on 1/30/2014.
//  Copyright (c) 2014 Rayyan Khoury. All rights reserved.
//

#import "MyScene.h"

// Enum representing what is contained within the array at this specific position for terrain
typedef enum
{
    base1,
    base2,
    coral,
    water
    
} TerrainType;

// Terrain Array that is accessible
NSMutableArray *terrainArray;

// Ship Array of this player
NSMutableArray *thisPlayer;

// Position of player 1 base;
NSMutableArray *player1BasePositions;

// Tracks the movable ship
static NSString * const kShipNodeName = @"movable";

@interface MyScene ()

@property (nonatomic, strong) SKSpriteNode *selectedShip;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        [self initTerrain];
        [self initShips];
    }
    return self;
}

/*
 Creates a randomly generated terrain.
 Uses the 30x30 cell space as specified, with the coral reef randomly generated each time
 so that 24 spaces within the 240 cells are allocated with coral.
 */
- (void)initTerrain {
    
    int width30 = self.frame.size.width / 30;
    int height30 = self.frame.size.height / 30;
    
    // Creating the terrain array
    NSNumber *base1Terrain = [NSNumber numberWithInt:base1];
    NSNumber *base2Terrain = [NSNumber numberWithInt:base2];
    NSNumber *coralTerrain = [NSNumber numberWithInt:coral];
    NSNumber *waterTerrain = [NSNumber numberWithInt:water];
    
    // Creating the two dimensional array
    // Outer array: rows
    
    int rowLength = 30;
    int numberOfRows = 30;
    
    terrainArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *innerArray;
    
    for (int i = 0; i < numberOfRows; i++)
    {
        innerArray = [[NSMutableArray alloc] init];
        [terrainArray addObject:innerArray];
    }
    
    // Creating the base arrays
    
    NSNumber *player1Base;
    player1BasePositions = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 10; i++)
    {
        player1Base = [NSNumber numberWithInt:(300 + (30 * i))];
        [player1BasePositions addObject:player1Base];
    }
    
    NSNumber *player2Base;
    NSMutableSet *player2BasePositions = [[NSMutableSet alloc] init];
    
    for (int i = 0; i < 10; i++)
    {
        player2Base = [NSNumber numberWithInt:(329 + (30 * i))];
        [player2BasePositions addObject:player2Base];
    }
    
    // Creating the random coral terrain array
    
    NSNumber *coralTemp;
    NSMutableSet *coralPositions = [[NSMutableSet alloc] init];
    
    while ([coralPositions count] < 24)
    {
        int colPos = 10 + arc4random_uniform(10);
        int rowPos = 3 + arc4random_uniform(24);
        coralTemp = [NSNumber numberWithInt:((rowPos * 30) + colPos)];
        
        for (NSNumber *contained in coralPositions)
        {
            if ([contained isEqualToNumber:coralTemp])
                continue;
            
        }
        
        [coralPositions addObject:coralTemp];
        
    }

    // Initializing the two dimensional array
    NSNumber *pos;
    
    bool isCoral = false;
    bool isPlayer1Base = false;
    bool isPlayer2Base = false;
    
    for (int i = 0; i < numberOfRows; i++)
    {
        innerArray = [terrainArray objectAtIndex:i];
        
        for (int j = 0; j < rowLength; j++)
        {
            isCoral = false;
            isPlayer1Base = false;
            isPlayer2Base = false;
            
            pos = [NSNumber numberWithInt:((i * 30) + j)];
            
            // Checking for coral
            for (NSNumber *corals in coralPositions)
            {
                if ([corals isEqualToNumber:pos])
                {
                    [innerArray addObject:coralTerrain];
                    isCoral = true;
                    break;
                }
                
            }
            
            if (isCoral) continue;
            
            // Checking for player1 base
            for (NSNumber *p1 in player1BasePositions)
            {
                if ([p1 isEqualToNumber:pos])
                {
                    [innerArray addObject:base1Terrain];
                    isPlayer1Base = true;
                    break;
                }
                
            }
            
            if (isPlayer1Base) continue;
            
            // Checking for player2 base
            for (NSNumber *p2 in player2BasePositions)
            {
                if ([p2 isEqualToNumber:pos])
                {
                    [innerArray addObject:base2Terrain];
                    isPlayer2Base = true;
                    break;
                }
                
            }
            
            if (isPlayer2Base) continue;
            
            // Otherwise regular water
            [innerArray addObject:waterTerrain];
            
        }
        
    }
    
    // Load the sprites
    SKSpriteNode *sprite = [[SKSpriteNode alloc] init];
    
    TerrainType ter;
    
    for (int i = 0; i < numberOfRows; i++)
    {
        innerArray = [terrainArray objectAtIndex:i];
        
        for (int j = 0; j < rowLength; j++)
        {
            ter = [[innerArray objectAtIndex:j] intValue];
            
            switch (ter)
            {
                case base1:
                    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"MidBase"];
                    sprite.zRotation = M_PI / 2;
                    break;
                    
                case base2:
                    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"MidBase"];
                    sprite.zRotation = 3 * M_PI / 2;
                    break;
                    
                case coral:
                    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Coral"];
                    sprite.zRotation = 3 * M_PI / 2;
                    break;
                    
                default:
                    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"PureWater"];
                    sprite.zRotation = M_PI / 2;
                    break;
            
            }
            
            sprite.yScale = 2.13;
            sprite.xScale = 1.55;
            sprite.position = CGPointMake(i*width30 + sprite.frame.size.width/2, j*height30 + sprite.frame.size.height/2);
            [self addChild:sprite];
        }
    }
}

/*
 Initializes the ship locations on the base.
 This method uses a previously instantiated array of ship locations for the ships to be loaded.
 Right now it randomly loads them in a position on its base.
 */
- (void)initShips {
    
    int width30 = self.frame.size.width / 30;
    int height30 = self.frame.size.height / 30;
    
    // Loading the images of the ships
    NSArray *imageNames = @[@"Cruiser",
                            @"Cruiser",
                            @"Destroyer",
                            @"Destroyer",
                            @"Destroyer",
                            @"TorpedoBoat",
                            @"TorpedoBoat",
                            @"MineLayer",
                            @"MineLayer",
                            @"RadarBoat"];
    
    // Copy the player base array
    NSMutableArray *shuffle = [[NSMutableArray alloc] initWithArray:player1BasePositions copyItems:YES];
    
    // Counts the numner of positions
    NSUInteger count = [shuffle count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [shuffle exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    // Load the sprites
    NSNumber *position;
    int pos;
    int width;
    int height;
    NSString *imageName;
    SKSpriteNode *sprite;
    
    for (int i = 0; i < [shuffle count]; i++)
    {
        imageName = [imageNames objectAtIndex:i];
        sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        
        position = [shuffle objectAtIndex:i];
        pos = [position intValue];
        
        width = pos / 30;
        height = pos % 30;
        
        sprite.yScale = 2.10;
        sprite.xScale = 1.55;
        sprite.position = CGPointMake(width*width30 + sprite.frame.size.width/2, height*height30 + sprite.frame.size.height/2);
        [self addChild:sprite];
        
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Pew"];
        
        sprite.position = location;
        
//        sprite.yScale = 2.1;
//        sprite.xScale = 1.55;
        
        //SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        //[sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
        
        
    }
    
    [self runAction:[SKAction playSoundFileNamed:@"Pew_Pew-DKnight556-1379997159.mp3" waitForCompletion:NO]];
    
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    
}

@end
