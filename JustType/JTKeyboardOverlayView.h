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

/**
 *  This should be called when the dragging began
 *  in order to set up the initial values for dragging.
 *
 *  @param fromPoint the starting point where touchdown happened
 */
- (void)draggingBeganFromPoint:(CGPoint)fromPoint;

/**
 *  This should be called to update the snap behavior.
 *
 *  @param fromPoint    the starting point where touchdown happened
 *  @param toPoint      the point where the cursor currently is
 *  @param isHorizontal indicates if the action is being horizontal or vertical
 */
- (void)visualizeDragFromPoint:(CGPoint)fromPoint
                       toPoint:(CGPoint)toPoint
                    horizontal:(BOOL)isHorizontal;

/**
 *  This is the teardown call to hide all visuals for dragging.
 */
- (void)draggingStopped;

@end

/**
 *  An overlay on top of the text element showing visual helps like arrows to indicate that a swipe was recognized on the keyboard.
 */
@interface JTKeyboardOverlayView : UIView <JTKeyboardOverlayViewProtocol, JTKeyboardOverlayFrameAnimationDelegate>

@property (nonatomic, retain) UIView *startCircleView;
@property (nonatomic, retain) UIView *endCircleView;

@end
