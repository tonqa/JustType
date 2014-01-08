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

@end

@implementation JTKeyboardOverlayView
@synthesize frameAnimations;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    self.frameAnimations = nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
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

@end
