//
//  JTKeyboardOverlayView.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  An overlay on top of the keyboard showing visual helps like arrows to indicate that a swipe was recognized on the keyboard.
 */
@interface JTKeyboardOverlayView : UIView

/**
 *  This trigger showing a line with an arrow showing in a certain direction. This line is then slowly faded out.
 *
 *  @param direction the direction type, e.g. JTKeyboardGestureSwipeUp
 */
- (void)fadeOutLineForDirection:(NSString *)direction;

@end
