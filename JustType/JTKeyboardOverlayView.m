//
//  JTKeyboardOverlayView.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTKeyboardOverlayView.h"
#import <QuartzCore/QuartzCore.h>
#import "JTKeyboardHeaders.h"

@interface JTKeyboardOverviewLayer : CALayer
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@end

@implementation JTKeyboardOverviewLayer
@synthesize startPoint;
@synthesize endPoint;
@end


@interface JTKeyboardOverlayView ()

- (void)drawLineInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint toPoint:(CGPoint)endPoint width:(CGFloat)width;
- (void)drawLineArrowInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint 
                       toPoint:(CGPoint)endPoint width:(CGFloat)width length:(CGFloat)length;

@end

@implementation JTKeyboardOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
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

- (void)fadeOutLineForDirection:(NSString *)direction {
    
    CGPoint startPoint, endPoint;
    
    if ([direction isEqualToString:JTKeyboardGestureSwipeLeftLong]) {
        startPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        endPoint = CGPointMake(self.frame.size.width*1./4., self.frame.size.height/2);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeRightLong]) {
        startPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        endPoint = CGPointMake(self.frame.size.width*3./4., self.frame.size.height/2);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeLeftShort]) {
        startPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        endPoint = CGPointMake(self.frame.size.width*3./8., self.frame.size.height/2);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeRightShort]) {
        startPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        endPoint = CGPointMake(self.frame.size.width*5./8., self.frame.size.height/2);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeUp]) {
        startPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height*5./8.);
        endPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height*3./8.);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeDown]) {
        startPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height*3./8.);
        endPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height*5./8.);
    } else {
        return;
    }
    
    JTKeyboardOverviewLayer *layer = [[JTKeyboardOverviewLayer alloc] init];
    layer.frame = self.layer.bounds;
    layer.masksToBounds = NO;
    layer.shadowColor = [[UIColor whiteColor] CGColor];
    layer.shadowOffset = CGSizeMake(0, 1);
    layer.shadowRadius = 0.5;
    layer.shadowOpacity = 0.2;
    layer.delegate = self;
    layer.startPoint = startPoint;
    layer.endPoint = endPoint;
    [self.layer addSublayer:layer];
    [layer setNeedsDisplay];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:0.5]];
    [animation setToValue:[NSNumber numberWithFloat:0.0]];
    [animation setDuration:1.0f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setRemovedOnCompletion:NO];
    [animation setAutoreverses:NO];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRepeatCount:0];
    [animation setDelegate:self];
    [layer addAnimation:animation forKey:@"opacity"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [[[self.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
}

#pragma mark - CALayerDelegate
- (void)drawLayer:(JTKeyboardOverviewLayer *)layer inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    if (layer.startPoint.x != 0.0 || layer.endPoint.x != 0.0f) {
        
        CGFloat width, arrowLength, arrowWidth;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            width = 10.0f, arrowLength = 5.0f, arrowWidth = 5.0f;
        } else {
            width = 20.0f, arrowLength = 10.0f, arrowWidth = 10.0f;
        }
        
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        
        [self drawLineInContext:context fromPoint:layer.startPoint 
                        toPoint:layer.endPoint width:width];
        
        [self drawLineArrowInContext:context fromPoint:layer.startPoint 
                             toPoint:layer.endPoint width:arrowWidth length:arrowLength];
    }
    
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

#pragma mark - internal methods
- (void)drawLineInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint 
                  toPoint:(CGPoint)endPoint width:(CGFloat)width {
    
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, beginPoint.x, beginPoint.y); //start at this point
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y); //draw to this point
}

- (void)drawLineArrowInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint 
                       toPoint:(CGPoint)endPoint width:(CGFloat)width length:(CGFloat)length {
    
    CGFloat r, ax, ay, bx, by, cx, cy, dx, dy;
    r = atan2(endPoint.y - beginPoint.y, 
              endPoint.x - beginPoint.x );
    r += M_PI;
    bx = endPoint.x;
    by = endPoint.y;
    dx = bx + cos(r) * length;
    dy = by + sin(r) * length;
    r += M_PI_2; // perpendicular to path
    ax = dx + cos(r) * width;
    ay = dy + sin(r) * width;
    cx = dx - cos(r) * width;
    cy = dy - sin(r) * width;
    
    CGContextMoveToPoint( context , ax , ay );
    CGContextAddLineToPoint( context , bx , by );
    CGContextAddLineToPoint( context , cx , cy );
    CGContextClosePath( context ); // for triangle
    
}

@end
