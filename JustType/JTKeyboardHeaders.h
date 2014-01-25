//
//  JTKeyboardHeaders.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_BELOW_IOS7() (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)

/**
 *  The notification identifier for posting that a gesture was recognized. This notification type triggers that the text input element can do the appropriate scrolling or editing.
 */
extern NSString * const JTNotificationTextControllerDidRecognizeGesture;

/**
 *  The notification identifier for confirming that a gesture was processed. This notification type triggers that circle point for confirmation are displayed on top of the keyboard afterwards.
 */
extern NSString * const JTNotificationTextControllerDidProcessGesture;

/**
 *  The notification identifier for confirming that an action was executed. This notification type triggers that an arrow for confirmation is displayed on top of the keyboard afterwards.
 */
extern NSString * const JTNotificationTextControllerDidExecuteAction;

/**
 *  Key for the userInfo dictionary of the notification with type JTNotificationTextControllerDidProcessGesture indicating the direction of the swipe.
 */
extern NSString * const JTNotificationKeyDirection;

/**
 *  Key for the userInfo dictionary of the notification with type JTNotificationTextControllerDidExecuteAction indicating an executed action.
 */
extern NSString * const JTNotificationKeyAction;

/**
 *  All currently supported gesture type constants.
 */

/**
 *  A gesture type constant for a left and long swipe. If the swipe on top of the keyboard was done with the right delta in a small amount of time it is recognized as a long swipe.
 */
extern NSString * const JTKeyboardGestureSwipeLeftLong;
/**
 *  A gesture type constant for a right and long swipe. If the swipe on top of the keyboard was done with the right delta in a small amount of time it is recognized as a long swipe.
 */
extern NSString * const JTKeyboardGestureSwipeRightLong;
/**
 *  A gesture type constant for a left and short swipe. If the swipe on top of the keyboard was done with a small delta in an amount of time it is recognized as a short swipe.
 */
extern NSString * const JTKeyboardGestureSwipeLeftShort;
/**
 *  A gesture type constant for a right and short swipe. If the swipe on top of the keyboard was done with a small delta in an amount of time it is recognized as a short swipe.
 */
extern NSString * const JTKeyboardGestureSwipeRightShort;
/**
 *  A gesture type constant for a long swipe upwards.
 */
extern NSString * const JTKeyboardGestureSwipeUp;
/**
 *  A gesture type constant for a long swipe downwards.
 */
extern NSString * const JTKeyboardGestureSwipeDown;

/**
 *  An action type constant for a upwards capitalization.
 */
extern NSString * const JTKeyboardActionCapitalized;

/**
 *  An action type constant to make the first letter lowercase.
 */
extern NSString * const JTKeyboardActionLowercased;
