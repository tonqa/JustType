//
//  JTDashedBorderedView.m
//  JustType
//
//  Created by Alexander Koglin on 02.01.14.
//
//

#import "JTDashedBorderedView.h"

@implementation JTDashedBorderedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat dashPattern[]= {5.0, 2};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);

    CGPoint fromPoint = CGPointMake(self.bounds.origin.x + 2,
                                    self.bounds.origin.y +
                                    self.bounds.size.height - 4);
    CGPoint toPoint = CGPointMake(self.bounds.origin.x +
                                  self.bounds.size.width + 2,
                                  self.bounds.origin.y +
                                  self.bounds.size.height - 4);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineDash(context, 0.0, dashPattern, 2);
    
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
    //CGContextAddRect(context, self.bounds);
    
    CGContextStrokePath(context);
    //CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
