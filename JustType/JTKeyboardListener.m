//
//  JTKeyboardListener.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTKeyboardListener.h"
#import "JTKeyboardOverlayView.h"

NSString * const JTKeyboardGestureSwipeLeftLong     = @"JTKeyboardGestureSwipeLeftLong";
NSString * const JTKeyboardGestureSwipeRightLong    = @"JTKeyboardGestureSwipeRightLong";
NSString * const JTKeyboardGestureSwipeLeftShort    = @"JTKeyboardGestureSwipeLeftShort";
NSString * const JTKeyboardGestureSwipeRightShort   = @"JTKeyboardGestureSwipeRightShort";
NSString * const JTKeyboardGestureSwipeUp           = @"JTKeyboardGestureSwipeUp";
NSString * const JTKeyboardGestureSwipeDown         = @"JTKeyboardGestureSwipeDown";


@interface JTKeyboardListener ()

@property (nonatomic, readonly) UIWindow *mainWindow;
@property (nonatomic, readonly) UIWindow *keyboardWindow;
@property (nonatomic, readonly) UIWindow *keyboardView;

@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;

@property (nonatomic, retain) JTKeyboardOverlayView *keyboardOverlayView;

@end


@implementation JTKeyboardListener
@synthesize panGesture = _panGesture;
@synthesize keyboardOverlayView = _keyboardOverlayView;

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

# pragma mark - Keyboard handling
- (void)keyboardDidShow:(NSNotification *)notification {
    // TODO: secure fetching those views
    UIView *keyboardView = self.keyboardView;
    NSAssert(keyboardView, @"No keyboard view found");
    
    // add own ABKeyboardOverlayView to KeyboardOverlay (just for giving hints)
    JTKeyboardOverlayView *transparentView = [[JTKeyboardOverlayView alloc] initWithFrame:keyboardView.bounds];
    transparentView.backgroundColor = [UIColor clearColor];
    transparentView.alpha = 1.0;
    transparentView.userInteractionEnabled = NO;
    [keyboardView addSubview:transparentView];
    self.keyboardOverlayView = transparentView;
    
    // add gesture recognizers to KeyboardView (for typing faster)
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [keyboardView addGestureRecognizer:recognizer];
    self.panGesture = recognizer;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // remove all the views and gestures
    
    [self.keyboardOverlayView removeFromSuperview];
    self.keyboardOverlayView = nil;
    
    [self.panGesture.view removeGestureRecognizer:self.panGesture];
    self.panGesture = nil;
}

# pragma mark - Gesture recognizers
- (void)panned:(UIPanGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
//        CGPoint startPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
//        [self.keyboardOverlayView drawLineFromPoint:startPoint];
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
//        CGPoint lastPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
//        [self.keyboardOverlayView drawLineToPoint:lastPoint];
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
//        [self.keyboardOverlayView drawLineFromPoint:CGPointZero];
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
//        [self.keyboardOverlayView drawLineFromPoint:CGPointZero];
        
        CGPoint velocity = [gestureRecognizer velocityInView:self.keyboardOverlayView];
        if (ABS(velocity.x) > ABS(velocity.y)) {
            if (velocity.x > 0) {
                NSLog(@"panned, gesture went right");
                [self.keyboardOverlayView blink];
                [[NSNotificationCenter defaultCenter] postNotificationName:JTKeyboardGestureSwipeRightLong object:self];
            } else {
                NSLog(@"panned, gesture went left");
                [self.keyboardOverlayView blink];
                [[NSNotificationCenter defaultCenter] postNotificationName:JTKeyboardGestureSwipeLeftLong object:self];
            }
        } else {
            if (velocity.y > 0) {
                NSLog(@"panned, gesture went down");
                [self.keyboardOverlayView blink];
                [[NSNotificationCenter defaultCenter] postNotificationName:JTKeyboardGestureSwipeDown object:self];
            } else {
                NSLog(@"panned, gesture went up");
                [self.keyboardOverlayView blink];
                [[NSNotificationCenter defaultCenter] postNotificationName:JTKeyboardGestureSwipeUp object:self];
            }
        }
        
    }
}

# pragma mark - private methods
- (UIWindow *)mainWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

- (UIWindow *)keyboardWindow {
    return [[[UIApplication sharedApplication] windows] objectAtIndex:1];
}

- (UIView *)keyboardView {
    return [[[self keyboardWindow] subviews] objectAtIndex:0];
}

@end
