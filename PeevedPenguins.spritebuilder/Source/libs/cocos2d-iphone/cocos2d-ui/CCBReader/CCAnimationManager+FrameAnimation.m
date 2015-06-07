//
//  CCBAnimationManager+FrameAnimation.m
//  cocos2d-ios
//
//  Created by Martin Walsh on 14/04/2014.
//
//

#import "CCAnimationManager+FrameAnimation.h"
#import "CCAnimationManager_Private.h"

@implementation CCAnimationManager (FrameAnimation)

- (void)animationWithSpriteFrames:animFrames delay:(float)delay name:(NSString*)name node:(CCNode*)node loop:(BOOL)loop{
    
    float nextTime = 0.0f;
    NSMutableArray *keyFrames = [[NSMutableArray alloc] init];
    
    for(NSString* frame in animFrames) {
        // Create Frame(s)
        NSDictionary* frameDict = @{@"value": frame,
                                   @"time": @(nextTime)};
        
        [keyFrames addObject:frameDict];
        nextTime+=delay;
    }
    
    // Return to first frame
    NSDictionary* frameDict = @{@"value": [animFrames firstObject],
                               @"time": @(nextTime)};
    
    [keyFrames addObject:frameDict];
    
    // Add Animation Sequence
    [self addKeyFramesForSequenceNamed:name propertyType:CCBSequencePropertyTypeSpriteFrame frameArray:keyFrames node:node loop:loop];
}

#pragma mark Legacy Animation Support
- (void)parseVersion1:(NSDictionary*)animations node:(CCNode*)node {
    
	NSArray* animationNames = [animations allKeys];
    NSMutableArray* animFrames = [[NSMutableArray alloc] init];
    
	for( NSString *name in animationNames ) {
        
        [animFrames removeAllObjects];
        
		NSDictionary* animationDict = animations[name];
		NSArray *frameNames = animationDict[@"frames"];
        
		float delay = [animationDict[@"delay"] floatValue];

		if ( frameNames == nil ) {
			CCLOG(@"Animation '%@' found in dictionary without any frames - Skipping", name);
			continue;
		}

		for( NSString *frameName in frameNames ) {
			CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
			
			if ( !spriteFrame ) {
				CCLOG(@"Animation '%@' refers to frame '%@' which is not currently in the CCSpriteFrameCache.  This frame will not be added to the animation - Skipping", name, frameName);
				continue;
			}
            
            [animFrames addObject:frameName];
		}
        
        [self animationWithSpriteFrames:animFrames delay:delay name:name node:node loop:YES];
	}
}

- (void)parseVersion2:(NSDictionary*)animations node:(CCNode*)node {
    
	NSArray* animationNames = [animations allKeys];
    NSMutableArray* animFrames = [[NSMutableArray alloc] init];
	
	for( NSString *name in animationNames ) {
        
        [animFrames removeAllObjects];
		NSDictionary* animationDict = animations[name];
        
		//int loops = [[animationDict objectForKey:@"loops"] intValue];
		//BOOL restoreOriginalFrame = [[animationDict objectForKey:@"restoreOriginalFrame"] boolValue];
        
		NSArray *frameArray = animationDict[@"frames"];
		
		if ( frameArray == nil ) {
			CCLOG(@"Animation '%@' found in dictionary without any frames - Skipping", name);
			continue;
		}
        
		for( NSDictionary *entry in frameArray ) {
			NSString *spriteFrameName = entry[@"spriteframe"];
			CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
			
			if ( !spriteFrame ) {
				CCLOG(@"Animation '%@' refers to frame '%@' which is not currently in the CCSpriteFrameCache.  This frame will not be added to the animation - Skipping", name, spriteFrameName);
				continue;
			}
            
            [animFrames addObject:spriteFrameName];
            
			//float delayUnits = [[entry objectForKey:@"delayUnits"] floatValue];
			//NSDictionary *userInfo = [entry objectForKey:@"notification"];
		}
		
		float delayPerUnit = [animationDict[@"delayPerUnit"] floatValue];

        [self animationWithSpriteFrames:animFrames delay:delayPerUnit name:name node:node loop:YES];
	}
}

- (void)addAnimationsWithDictionary:(NSDictionary *)dictionary node:(CCNode*)node {
	NSDictionary *animations = dictionary[@"animations"];
    
	if ( animations == nil ) {
		CCLOG(@"No animations were found in dictionary.");
		return;
	}
	
	NSUInteger version = 1;
	NSDictionary *properties = dictionary[@"properties"];
	if( properties ) {
		version = [properties[@"format"] intValue];
    }
	
	NSArray *spritesheets = properties[@"spritesheets"];
    
    // Ensure Sheets Loaded
	for( NSString *name in spritesheets ) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:name];
    }
    
	switch (version) {
		case 1:
			[self parseVersion1:animations node:node];
			break;
		case 2:
			[self parseVersion2:animations node:node];
			break;
		default:
			NSAssert(NO, @"Invalid animation format.");
	}
}


- (void)addAnimationsWithFile:(NSString *)plist node:(CCNode*)node {
    
    NSString *path     = [[CCFileUtils sharedFileUtils] fullPathForFilename:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
	NSAssert1( dict, @"Animation file could not be found: %@", plist);
    
	[self addAnimationsWithDictionary:dict node:node];
}

@end
