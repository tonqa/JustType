//
//  JTKeyboardGestureRecognizer.m
//  JustType
//
//  Created by Alexander Koglin on 31.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTKeyboardGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#if TARGET_IPHONE_SIMULATOR
    #define SWIPE_PIXEL_THRESHOLD 30.0f
    #define SWIPE_TIMEINTERVAL_THRESHOLD 0.5
#else
    // thresholds should be narrower
    // when swiping on a real device
    #define SWIPE_PIXEL_THRESHOLD 30.0f
    #define SWIPE_TIMEINTERVAL_THRESHOLD 0.1
#endif

@interface JTKeyboardGestureRecognizer ()

@property (nonatomic, assign) BOOL wasRecognized;

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, retain) NSDate *startTime;

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, retain) NSDate *lastTime;

@end


@implementation JTKeyboardGestureRecognizer
@synthesize wasRecognized = _wasRecognized;
@synthesize startPoint = _startPoint;
@synthesize startTime = _startTime;

- (void)reset {
    [super reset];
    
    self.state = UIGestureRecognizerStatePossible;
    self.wasRecognized = NO;
    self.startTime = nil;
    self.startPoint = CGPointZero;
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count > 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self.view];
    self.startTime = [NSDate date];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    // if it was not recognized yet check if it was move fast enough
    if (self.state == UIGestureRecognizerStatePossible) {
        
        if (-[self.startTime timeIntervalSinceNow] >= SWIPE_TIMEINTERVAL_THRESHOLD) {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }

        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];

        if ([self distanceBetween:self.startPoint and:currentPoint] >= SWIPE_PIXEL_THRESHOLD) {
            self.state = UIGestureRecognizerStateBegan;
            self.wasRecognized = YES;
        }
    } else if (self.wasRecognized) {
        // if gesture was already recognized, then sent regular point updates
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.wasRecognized) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (CGFloat)distanceBetween:(CGPoint)p1 and:(CGPoint)p2 {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

@end
