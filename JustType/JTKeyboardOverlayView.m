//
//  JTKeyboardOverlayView.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTKeyboardOverlayView.h"
#import <QuartzCore/QuartzCore.h>

@interface JTKeyboardOverlayView ()

@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint lastPoint;

- (void)drawLineInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint toPoint:(CGPoint)endPoint width:(CGFloat)width;
- (void)drawLineArrowInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint 
                       toPoint:(CGPoint)endPoint width:(CGFloat)width length:(CGFloat)length;

@end

@implementation JTKeyboardOverlayView
@synthesize startPoint;
@synthesize lastPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.startPoint = CGPointZero;
        self.lastPoint = CGPointZero;
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

- (void)drawLineFromPoint:(CGPoint)fromPoint {
    self.startPoint = fromPoint;
    self.lastPoint = fromPoint;
    [self setNeedsDisplay];
}

- (void)drawLineToPoint:(CGPoint)toPoint {
    self.lastPoint = toPoint;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.startPoint.x != 0.0 || self.lastPoint.x != 0.0f) {
        
        CGFloat length = 5.0f, width = 3.0f;
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        
        [self drawLineInContext:context fromPoint:self.startPoint 
                        toPoint:self.lastPoint width:width];
        
        [self drawLineArrowInContext:context fromPoint:self.startPoint 
                             toPoint:self.lastPoint width:width length:length];
    }
    
    CGContextStrokePath(context);
    
}

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
