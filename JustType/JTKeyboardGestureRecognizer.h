//
//  JTKeyboardGestureRecognizer.h
//  JustType
//
//  Created by Alexander Koglin on 31.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This is an own gesture recognizer which gets installed on the top of the keyboard every time the keyboard shows up. It is necessary in order to not interfere with existing gestures on the keyboard. 
 *
 * If we would install a normal UIPanGestureRecognizer, then some keyboard gestures (like long taps) would stop working. This KeyboardGestureRecognizer tries to circumvent this by only recognizing a gesture if a distance is exceeded after a certain time threshold.
 */
@interface JTKeyboardGestureRecognizer : UIGestureRecognizer

@end
