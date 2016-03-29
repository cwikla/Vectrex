//
//  HelloWorldLayer.m
//  Vectrex
//
//  Created by John Cwikla on 6/1/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "VectrexLayer.h"
#import "vecx.h"
#import "osint.h"

#define ROM_FILE_NAME  "rom.dat"


// HelloWorldLayer implementation
@implementation VectrexLayer


@synthesize scale;
@synthesize offset;


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	VectrexLayer *layer = [VectrexLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)loadRom {
    memset(cart, 0, sizeof (cart));
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rom" ofType:@"dat"];  
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    memset(rom, 0, sizeof(rom)/sizeof(rom[0]));
    memcpy(rom, [data bytes], sizeof(rom));

    filePath = [[NSBundle mainBundle] pathForResource:@"ARMOR" ofType:@"BIN"];  
    data = [NSData dataWithContentsOfFile:filePath];

    memset(cart, 0, sizeof(cart)/sizeof(cart[0]));
    memcpy(cart, [data bytes], [data length]);
}
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {		
        self.isTouchEnabled = YES;

		// ask director the the window size
        
        if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] ) {
            [CCDirector setDirectorType:CCDirectorTypeDefault];
        }
        
        [[CCDirector sharedDirector] setAnimationInterval:1.0/30.0]; // VECTREX_MHZ];
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        long scale_x = ALG_MAX_X / size.width;
        long scale_y = ALG_MAX_Y / size.height;
        
        self.scale = scale_x > scale_y ? scale_x : scale_y;
        self.offset = ccp(0,0); // ccp(0,100); // ccp((ALG_MAX_X / self.scale) / 2, 0); //(ALG_MAX_Y / self.scale) / 2);
        
        //[self scheduleUpdate:@selector(gameLoop:)];
        vecx_reset();
        [self loadRom];
        
       // [self schedule:@selector(gameLoop:) interval: 1/60.0f];
        [self scheduleUpdate];
	}
	return self;
}

- (void)update: (ccTime)deltaTime
{
    [self gameLoop:deltaTime];
}

- (void) gameLoop: (ccTime)deltaTime
{   
 //  NSLog(@"game.Tick dt:%f", deltaTime);
    vecx_emu(VECTREX_MHZ /30 , 0); //* deltaTime, 0);
}

- (void)draw {
   // [super draw];
    
    long draw_count = vector_draw_cnt;
    long erase_count = vector_erse_cnt;
    vector_t *to_draw = vectors_draw;
    vector_t *to_erase = vectors_erse;
    
    if (draw_count == 0) {
     //   NSLog(@"Draw count is 0");
        to_draw = to_erase;
        draw_count = erase_count;
    }
    
    // ...
    
    // draw a simple line
    // The default state is:
    // Line Width: 1
    // color: 255,255,255,255 (white, non-transparent)
    // Anti-Aliased
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    glEnable(GL_LINE_SMOOTH);
//    ccDrawLine( ccp(0, 0), ccp(s.width, s.height) );
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    
    long offset_x = self.offset.x;
    long offset_y = self.offset.y;
    
    
    glColor4ub(0,0,0,255);
	int v;
    
#if 0
    
	for(v = 0; v < erase_count; v++){
        if (to_erase[v].color == VECTREX_COLORS) {
            continue;
        }
        CGPoint pt_start = ccp(offset_x + to_erase[v].x0 / self.scale,
                               s.height - (offset_y + to_erase[v].y0 / self.scale));
        CGPoint pt_end = ccp(offset_x + to_erase[v].x1 / self.scale,
                             s.height - (offset_y + to_erase[v].y1 / self.scale));
        ccDrawLine(pt_start, pt_end);
	}
#endif
    
    glColor4ub(255,255,255,255);
    
   // NSLog(@"Vector count %d", (int)draw_count);
	for(v = 0; v < draw_count; v++){
        if (to_draw[v].color == VECTREX_COLORS) {
            continue;
        }
		int color = (to_draw[v].color * 255) / (VECTREX_COLORS-1);
     //   NSLog(@"Color %d", color);
        glColor4ub(color,color,color,255);
        
        CGPoint pt_start = ccp(offset_x + to_draw[v].x0 / self.scale,
                               s.height - (offset_y + to_draw[v].y0 / self.scale));
        CGPoint pt_end = ccp(offset_x + to_draw[v].x1 / self.scale,
                             s.height - (offset_y + to_draw[v].y1 / self.scale));
        ccDrawLine(pt_start, pt_end);
	}
 
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);        
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
//    [self selectButtonForTouch:touchLocation];      
    return TRUE;    
}

- (BOOL)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event { 
#if 0
    if (self.selectedButton != nil)
    {
        [self.selectedButton setSelected:false];
        self.selectedButton = nil;
        return TRUE;
    }
#endif
    return FALSE;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
