//
//  JTKeyboardOverlayViewDelegate.m
//  JustType
//
//  Created by Alexander Koglin on 08.01.14.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JTKeyboardOverlayFrameAnimation.h"
#import "JTKeyboardHeaders.h"

@interface JTKeyboardOverviewLayer : CALayer
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@end

@implementation JTKeyboardOverviewLayer
@synthesize startPoint;
@synthesize endPoint;
@end

@interface JTKeyboardOverlayFrameAnimation()

@property JTKeyboardOverviewLayer *layer;

- (void)drawLineInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint toPoint:(CGPoint)endPoint width:(CGFloat)width;
- (void)drawLineArrowInContext:(CGContextRef)context fromPoint:(CGPoint)beginPoint
toPoint:(CGPoint)endPoint width:(CGFloat)width length:(CGFloat)length;

@end

@implementation JTKeyboardOverlayFrameAnimation
@synthesize layer = _layer;

- (void)startAnimationForView:(UIView *)view arrowDirection:(NSString *)direction {
    CGPoint startPoint, endPoint;
    CGRect frame = view.frame;
    
    if ([direction isEqualToString:JTKeyboardActionCapitalized]) {
        startPoint = CGPointMake(frame.size.width/2, frame.size.height*5./8.);
        endPoint = CGPointMake(frame.size.width/2, frame.size.height*3./8.);
    } else if ([direction isEqualToString:JTKeyboardActionLowercased]) {
        startPoint = CGPointMake(frame.size.width/2, frame.size.height*3./8.);
        endPoint = CGPointMake(frame.size.width/2, frame.size.height*5./8.);
    }
    
    [self startAnimationForView:view fromPoint:startPoint toPoint:endPoint];
}

- (void)startAnimationForView:(UIView *)view fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    JTKeyboardOverviewLayer *layer = [[JTKeyboardOverviewLayer alloc] init];
    layer.frame = view.layer.bounds;
    layer.masksToBounds = NO;
    layer.shadowColor = [[UIColor whiteColor] CGColor];
    layer.shadowOffset = CGSizeMake(0, 1);
    layer.shadowRadius = 0.5;
    layer.shadowOpacity = 0.2;
    layer.opacity = 0.35;
    layer.delegate = self;
    layer.startPoint = fromPoint;
    layer.endPoint = toPoint;
    [layer setNeedsDisplay];
    [view.layer addSublayer:layer];
    self.layer = layer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:0.35]];
    [animation setToValue:[NSNumber numberWithFloat:0.0]];
    [animation setBeginTime:CACurrentMediaTime() + 0.8f];
    [animation setDuration:1.0f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setRemovedOnCompletion:NO];
    [animation setAutoreverses:NO];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRepeatCount:0];
    [animation setDelegate:self];
    [layer addAnimation:animation forKey:@"opacity"];
}

- (void)dealloc {
    [self.layer removeAnimationForKey:@"opacity"];
    [self.layer removeFromSuperlayer];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.layer removeFromSuperlayer];
    [self.delegate frameAnimationDidStop:self];
}

#pragma mark - CALayerDelegate
- (void)drawLayer:(JTKeyboardOverviewLayer *)layer inContext:(CGContextRef)context {
    
    UIGraphicsPushContext(context);
    
    if (layer.startPoint.x != 0.0 || layer.endPoint.x != 0.0f) {
        
        CGFloat width, arrowLength, arrowWidth;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            width = 10.0f, arrowLength = 8.0f, arrowWidth = 6.0f;
        } else {
            width = 20.0f, arrowLength = 10.0f, arrowWidth = 8.0f;
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
