//
//  JTTextController.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextController.h"
#import "JTKeyboardHeaders.h"

#import "JTSyntaxWord.h"
#import "JTSyntaxLinguisticWord.h"
#import "JTSyntaxSeperatorWord.h"

@interface JTTextController ()

@property (nonatomic, readonly) NSString *textContent;

@end


@implementation JTTextController
@synthesize delegate = _delegate;

extern NSString * const JTKeyboardGestureSwipeLeftLong;
extern NSString * const JTKeyboardGestureSwipeRightLong;
extern NSString * const JTKeyboardGestureSwipeLeftShort;
extern NSString * const JTKeyboardGestureSwipeRightShort;
extern NSString * const JTKeyboardGestureSwipeUp;
extern NSString * const JTKeyboardGestureSwipeDown;

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
        [notifCenter addObserver:self selector:@selector(didSwipeLeftLong:) name:JTKeyboardGestureSwipeLeftLong object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeRightLong:) name:JTKeyboardGestureSwipeRightLong object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeLeftShort:) name:JTKeyboardGestureSwipeLeftShort object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeRightShort:) name:JTKeyboardGestureSwipeRightShort object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeUp:) name:JTKeyboardGestureSwipeUp object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeDown:) name:JTKeyboardGestureSwipeDown object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - textview / textfield notifier methods
- (void)didChangeSelection {
    
}

- (void)didChangeText {
    
}

#pragma mark - notification listeners
- (void)didSwipeLeftLong:(NSNotification *)notification {
    
}

- (void)didSwipeRightLong:(NSNotification *)notification {
    
}

- (void)didSwipeLeftShort:(NSNotification *)notification {
    
}

- (void)didSwipeRightShort:(NSNotification *)notification {
    
}

- (void)didSwipeUp:(NSNotification *)notification {
    
}

- (void)didSwipeDown:(NSNotification *)notification {
    
}

#pragma mark - internal methods
- (NSString *)textContent {
    return [self.delegate textContent];
}

@end
