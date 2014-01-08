//
//  JTKeyboardOverlayView.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTKeyboardOverlayFrameAnimation.h"

/**
 *  A protocol which an overlay view must implement to show visual helps like arrows to indicate that a swipe was recognized on the keyboard.
 */
@protocol JTKeyboardOverlayViewProtocol <NSObject>

/**
 *  This trigger showing a line with an arrow showing in a certain direction. This line is then slowly faded out.
 *
 *  @param direction the direction type, e.g. JTKeyboardGestureSwipeUp
 */
- (void)visualizeDirection:(NSString *)direction;

@end

/**
 *  An overlay on top of the text element showing visual helps like arrows to indicate that a swipe was recognized on the keyboard.
 */
@interface JTKeyboardOverlayView : UIView <JTKeyboardOverlayViewProtocol, JTKeyboardOverlayFrameAnimationDelegate>

@end
