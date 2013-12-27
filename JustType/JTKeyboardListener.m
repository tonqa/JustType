//
//  JTKeyboardListener.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTKeyboardListener.h"

NSString * const JTKeyboardGestureSwipeLeftLong     = @"JTKeyboardGestureSwipeLeftLong";
NSString * const JTKeyboardGestureSwipeRightLong    = @"JTKeyboardGestureSwipeRightLong";
NSString * const JTKeyboardGestureSwipeLeftShort    = @"JTKeyboardGestureSwipeLeftShort";
NSString * const JTKeyboardGestureSwipeRightShort   = @"JTKeyboardGestureSwipeRightShort";
NSString * const JTKeyboardGestureSwipeUp           = @"JTKeyboardGestureSwipeUp";
NSString * const JTKeyboardGestureSwipeDown         = @"JTKeyboardGestureSwipeDown";


@implementation JTKeyboardListener

# pragma mark - object lifecycle
+ (id)sharedInstance {
    static JTKeyboardListener *sharedKeyboardListener;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedKeyboardListener = [[JTKeyboardListener alloc] init];
    });
    
    return sharedKeyboardListener;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

# pragma mark - public methods
- (void)observeKeyboardGestures:(BOOL)activate {
    if (activate) {
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) 
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                     name:UIKeyboardWillHideNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


# pragma mark - private methods
- (UIWindow *)mainWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

- (UIWindow *)keyboardWindow {
    return [[[UIApplication sharedApplication] windows] objectAtIndex:1];
}

@end
