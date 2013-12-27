//
//  JTKeyboardOverlayView.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTKeyboardOverlayView : UIView

- (void)blink;
- (void)drawLineFromPoint:(CGPoint)fromPoint;
- (void)drawLineToPoint:(CGPoint)toPoint;
- (void)resetLine;

@end
