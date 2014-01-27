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

- (UIColor *)strokeColor {
    if (!_strokeColor) {
        if ([self.window respondsToSelector:@selector(tintColor)]) {
            _strokeColor = self.window.tintColor;
        }
        
        if (!_strokeColor) {
            // there is no tint color until iOS6
            _strokeColor = [UIColor grayColor];
        }
    }
    return _strokeColor;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGFloat dashPattern[]= {5.0, 1};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);

    CGPoint fromPoint = CGPointMake(self.bounds.origin.x,
                                    self.bounds.origin.y +
                                    self.bounds.size.height);
    
    CGPoint toPoint = CGPointMake(self.bounds.origin.x +
                                  self.bounds.size.width,
                                  self.bounds.origin.y +
                                  self.bounds.size.height);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineDash(context, 0.0, dashPattern, 2);
    
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
    
    CGContextStrokePath(context);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
