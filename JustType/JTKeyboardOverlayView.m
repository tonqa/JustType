//
//  JTKeyboardOverlayView.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JTKeyboardOverlayView.h"


@interface JTKeyboardOverlayView ()

@property (nonatomic, retain) NSMutableArray *frameAnimations;
@property (nonatomic, retain) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;

@end

@implementation JTKeyboardOverlayView
@synthesize frameAnimations;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIColor *startCircleColor = nil;
        if ([self.window respondsToSelector:@selector(tintColor)]) {
            startCircleColor = self.window.tintColor;
        }
        
        if (!startCircleColor) {
            // there is no tint color until iOS6
            startCircleColor = [UIColor blueColor];
        }
        
        UIColor *endCircleColor = [self colorWithModifiedAlpha:0.80 forColor:startCircleColor];
//        UIColor *endCircleColor = [self complementaryColorForColor:startCircleColor];
        
        _startCircleView = [self createCircleViewWithSize:CGSizeMake(30, 30)];
        _startCircleView.backgroundColor = endCircleColor;
        [self addSubview:_startCircleView];

        _endCircleView = [self createCircleViewWithSize:CGSizeMake(50, 50)];
        _endCircleView.backgroundColor = endCircleColor;
        [self addSubview:_endCircleView];

        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

    }
    return self;
}

- (void)dealloc {
    self.frameAnimations = nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

- (void)visualizeDragFromPoint:(CGPoint)fromPoint
                       toPoint:(CGPoint)toPoint
                    horizontal:(BOOL)isHorizontal {

    CGPoint planarPoint;
    if (isHorizontal) {
        planarPoint = CGPointMake(toPoint.x, fromPoint.y);
    } else {
        planarPoint = CGPointMake(fromPoint.x, toPoint.y);
    }
    
    // Replace the previous behavior
    if (self.animator) {
        [self.animator removeBehavior:self.snapBehavior];
        UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self.endCircleView
                                                                snapToPoint:planarPoint];
        [self.animator addBehavior:snapBehavior];
        self.snapBehavior = snapBehavior;
    } else {
        self.endCircleView.center = planarPoint;
    }
    
}

- (void)draggingBeganFromPoint:(CGPoint)fromPoint {
    self.startCircleView.alpha = 0.5;
    self.endCircleView.alpha = 0.5;
    self.startCircleView.center = fromPoint;
    self.endCircleView.center = fromPoint;
}

- (void)draggingStopped {
    self.startCircleView.alpha = 0.0;
    self.endCircleView.alpha = 0.0;
}

- (void)visualizeDirection:(NSString *)direction {
    
    JTKeyboardOverlayFrameAnimation *frameAnimation = [[JTKeyboardOverlayFrameAnimation alloc] init];
    frameAnimation.delegate = self;
    
    [frameAnimation startAnimationForView:self arrowDirection:direction];
    
    [self.frameAnimations addObject:frameAnimation];
}

- (void)frameAnimationDidStop:(JTKeyboardOverlayFrameAnimation *)animation {
    [self.frameAnimations removeObject:animation];
}

- (void)blink {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.5]];
    [animation setDuration:0.05f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setAutoreverses:YES];
    [animation setRepeatCount:1];
    [[self layer] addAnimation:animation forKey:@"opacity"];
}

- (UIView *)createCircleViewWithSize:(CGSize)size {
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  size.width,
                                                                  size.height)];
    circleView.alpha = 0.0;
    circleView.layer.cornerRadius = (size.width + size.height) / 4.0;
    circleView.layer.backgroundColor = UIColor.clearColor.CGColor;
    circleView.userInteractionEnabled = NO;
    
    CABasicAnimation *stetchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    stetchAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.1, 1.1)];
    stetchAnimation.removedOnCompletion = NO;
    stetchAnimation.fillMode = kCAFillModeForwards;
    stetchAnimation.duration = (arc4random() % 50 / 50.0f) + 0.3f;
    stetchAnimation.repeatCount = HUGE_VALF;
    stetchAnimation.autoreverses = YES;
    [stetchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [circleView.layer addAnimation:stetchAnimation forKey:@"animations"];

    return circleView;
}

- (UIColor *)colorWithModifiedAlpha:(CGFloat)alpha forColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)complementaryColorForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    
    return [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:1];
}

@end
