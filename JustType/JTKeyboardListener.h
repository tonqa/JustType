//
//  JTKeyboardListener.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JTKeyboardListener : NSObject <UIGestureRecognizerDelegate>

+ (id)sharedInstance;

@property (nonatomic, assign, getter = isVisualHelpEnabled) BOOL enableVisualHelp;

- (void)observeKeyboardGestures:(BOOL)activate;

- (BOOL)keyboardIsAvailable;

@end
