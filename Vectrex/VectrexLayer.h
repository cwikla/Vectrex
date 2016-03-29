//
//  VectrexLayer.h
//  Vectrex
//
//  Created by John Cwikla on 6/1/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "vecx.h"

// VectrexLayer
@interface VectrexLayer : CCLayer

@property (readwrite,assign) long scale;
@property (readwrite,assign) CGPoint offset;


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (BOOL)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)gameLoop: (ccTime)deltaTime;
- (void)update: (ccTime)deltaTime;
- (void)draw;
- (void)loadRom;




// returns a CCScene that contains the VectrexLayer as the only child
+(CCScene *) scene;

@end
