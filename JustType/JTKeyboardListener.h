//
//  JTKeyboardListener.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  The keyboard listener recognizes swipes on top of the keyboard and displays visual helps on top of it when swipes were done.
 */
@interface JTKeyboardListener : NSObject <UIGestureRecognizerDelegate>

/**
 *  This is the only instance that should exist for the keyboard listener, which recognizes swipes on top of the keyboard and displays visual helps on top of it when swipes were done.
 *
 *  @return shared instance of the keyboard listener
 */
+ (id)sharedInstance;

/**
 *  Enables or disables visual helps on top of the keyboard. Visual helps are showing arrows in the direction, in which the swipe was done.
 */
@property (nonatomic, assign, getter = isVisualHelpEnabled) BOOL enableVisualHelp;

/**
 *  Color property to adapt the color of the circle displayed on touched down.
 */
@property (nonatomic, retain) UIColor *touchDownColor;

/**
 *  Color property to adapt the color of the circle displayed for move events.
 */
@property (nonatomic, retain) UIColor *touchMoveColor;

/**
 *  This enables the listening for swipe events by adding a gesture recognizer to the keyboard. If a swipe was triggered the listener sends out events of the type JTNotificationTextControllerDidProcessGesture, which other elements can observe then.
 *
 *  @param activate a boolean flag indicating if the listener should observe events of the keyboard
 *
 *  @see JTNotificationTextControllerDidProcessGesture
 */
- (void)observeKeyboardGestures:(BOOL)activate;

@end
