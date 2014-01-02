//
//  JTKeyboardListener.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTKeyboardListener.h"
#import "JTKeyboardOverlayView.h"
#import "JTKeyboardGestureRecognizer.h"

NSString * const JTKeyboardGestureSwipeLeftLong     = @"JTKeyboardGestureSwipeLeftLong";
NSString * const JTKeyboardGestureSwipeRightLong    = @"JTKeyboardGestureSwipeRightLong";
NSString * const JTKeyboardGestureSwipeLeftShort    = @"JTKeyboardGestureSwipeLeftShort";
NSString * const JTKeyboardGestureSwipeRightShort   = @"JTKeyboardGestureSwipeRightShort";
NSString * const JTKeyboardGestureSwipeUp           = @"JTKeyboardGestureSwipeUp";
NSString * const JTKeyboardGestureSwipeDown         = @"JTKeyboardGestureSwipeDown";

#define SWIPE_LONGSWIPE_WIDTH 100.0
#define SAMPLE_TIME_SECS_INITIAL 0.4
#define SAMPLE_TIME_SECS_MAX 0.3
#define SAMPLE_TIME_SECS_MIDDLE 0.2
#define SAMPLE_TIME_SECS_MIN 0.1

@interface JTKeyboardListener ()

@property (nonatomic, readonly) UIWindow *mainWindow;
@property (nonatomic, readonly) UIWindow *keyboardWindow;
@property (nonatomic, readonly) UIWindow *keyboardView;

@property (nonatomic, retain) UIGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint gestureStartingPoint;
@property (nonatomic, assign) CGPoint gestureMovementPoint;
@property (nonatomic, assign) NSUInteger timesOccurred;
@property (nonatomic, retain) NSString *lastSwipeDirection;
@property (nonatomic, assign) BOOL panGestureInProgress;


@property (nonatomic, retain) JTKeyboardOverlayView *keyboardOverlayView;

- (void)cleanupViewsAndGestures;
- (void)storeStartingPointWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)sendNotificationForLastSwipeDirection;
- (void)sendNotificationForSwipeDirection:(NSString *)swipeDirection;
- (void)checkGestureResult;
- (void)doPolling;
- (void)stopPollingAndCleanGesture;
- (void)recomputeSwipeDirection;

@end


@implementation JTKeyboardListener 
@synthesize panGesture = _panGesture;
@synthesize keyboardOverlayView = _keyboardOverlayView;
@synthesize gestureStartingPoint = _gestureStartingPoint;
@synthesize gestureMovementPoint = _gestureMovementPoint;
@synthesize timesOccurred = _timesOccurred;
@synthesize lastSwipeDirection = _lastSwipeDirection;
@synthesize panGestureInProgress = _panGestureInProgress;

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
        [self cleanupViewsAndGestures];
    }
}

# pragma mark - Keyboard handling
- (void)keyboardDidShow:(NSNotification *)notification {
    UIView *keyboardView = self.keyboardView;
    
    if (!keyboardView) {
        NSLog(@"Keyboard view is not at the expected place, \n \
              probably you use incompatible version of iOS. \n \
              The keyboard functionality is skipped");
    }
    
    // add own ABKeyboardOverlayView to KeyboardOverlay (just for giving hints)
    JTKeyboardOverlayView *transparentView = [[JTKeyboardOverlayView alloc] initWithFrame:keyboardView.bounds];
    transparentView.backgroundColor = [UIColor clearColor];
    transparentView.alpha = 1.0;
    transparentView.userInteractionEnabled = NO;
    [keyboardView addSubview:transparentView];
    self.keyboardOverlayView = transparentView;
    
    // add gesture recognizers to KeyboardView (for typing faster)
    JTKeyboardGestureRecognizer *pan = [[JTKeyboardGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    pan.delegate = self;
    [keyboardView addGestureRecognizer:pan];
    self.panGesture = pan;
        
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self cleanupViewsAndGestures];
}

- (void)cleanupViewsAndGestures {
    // remove all the views and gestures
    [self.keyboardOverlayView removeFromSuperview];
    self.keyboardOverlayView = nil;
    
    [self.panGesture.view removeGestureRecognizer:self.panGesture];
    self.panGesture = nil;
}

# pragma mark - Gesture recognizers
- (void)panned:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.gestureStartingPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
        self.gestureMovementPoint = self.gestureStartingPoint;
        self.panGestureInProgress = YES;
        [self performSelector:@selector(checkGestureResult) withObject:nil afterDelay:SAMPLE_TIME_SECS_MIDDLE];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        self.gestureMovementPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        self.panGestureInProgress = NO;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
        [self stopPollingAndCleanGesture];
    }
}

- (void)checkGestureResult {

    [self recomputeSwipeDirection];
    
    self.timesOccurred = 0;
    [self sendNotificationForSwipeDirection:self.lastSwipeDirection];
    [self.keyboardOverlayView fadeOutLineForDirection:self.lastSwipeDirection];
    [self performSelector:@selector(doPolling) withObject:nil afterDelay:SAMPLE_TIME_SECS_INITIAL];
}

- (void)doPolling {
    if (self.panGestureInProgress) {
        [self sendNotificationForLastSwipeDirection];
        NSTimeInterval delay;
        if (self.timesOccurred < 4) {
            delay = SAMPLE_TIME_SECS_MAX;
        } else if (self.timesOccurred < 12) {
            delay = SAMPLE_TIME_SECS_MIDDLE;
        } else {
            delay = SAMPLE_TIME_SECS_MIN;
        }
        [self performSelector:@selector(doPolling) withObject:nil afterDelay:delay];
        self.timesOccurred++;
    } else {
        [self stopPollingAndCleanGesture];
    }
}

- (void)stopPollingAndCleanGesture {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    self.gestureStartingPoint = CGPointZero;
    self.gestureMovementPoint = CGPointZero;
    self.lastSwipeDirection = nil;
    self.panGestureInProgress = NO;
}

- (void)storeStartingPointWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // store the starting point
    self.gestureStartingPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
}

- (void)sendNotificationForLastSwipeDirection {
    NSString *swipeDirection = self.lastSwipeDirection;

    if ([self.lastSwipeDirection isEqualToString:JTKeyboardGestureSwipeUp] ||
        [self.lastSwipeDirection isEqualToString:JTKeyboardGestureSwipeDown]) return;

    [self recomputeSwipeDirection];
    [self sendNotificationForSwipeDirection:swipeDirection];
}

- (void)recomputeSwipeDirection {
    CGPoint diffPoint = CGPointMake(
                                    self.gestureMovementPoint.x - self.gestureStartingPoint.x,
                                    self.gestureMovementPoint.y - self.gestureStartingPoint.y);
    CGPoint absDiffPoint = CGPointMake(ABS(diffPoint.x), ABS(diffPoint.y));
    
    if ([self.lastSwipeDirection isEqualToString:JTKeyboardGestureSwipeLeftShort] ||
        [self.lastSwipeDirection isEqualToString:JTKeyboardGestureSwipeLeftLong] ||
        [self.lastSwipeDirection isEqualToString:JTKeyboardGestureSwipeRightShort] ||
        [self.lastSwipeDirection isEqualToString:JTKeyboardGestureSwipeRightLong] ||
        absDiffPoint.x >= absDiffPoint.y) {
        if (diffPoint.x < 0) {
            if (absDiffPoint.x < SWIPE_LONGSWIPE_WIDTH) {
                self.lastSwipeDirection = JTKeyboardGestureSwipeLeftShort;
            } else {
                self.lastSwipeDirection = JTKeyboardGestureSwipeLeftLong;
            }
        } else {
            if (absDiffPoint.x < SWIPE_LONGSWIPE_WIDTH) {
                self.lastSwipeDirection = JTKeyboardGestureSwipeRightShort;
            } else {
                self.lastSwipeDirection = JTKeyboardGestureSwipeRightLong;
            }
        }
    } else {
        if (diffPoint.y < 0) {
            self.lastSwipeDirection = JTKeyboardGestureSwipeUp;
        } else {
            self.lastSwipeDirection = JTKeyboardGestureSwipeDown;
        }
    }
}

- (void)sendNotificationForSwipeDirection:(NSString *)swipeDirection {
    [[NSNotificationCenter defaultCenter] postNotificationName:swipeDirection object:self];
}

- (BOOL)keyboardIsAvailable {
    return [self keyboardView] != nil;
}

# pragma mark - private methods
- (UIWindow *)mainWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

/*
 * Fetches the keyboard window, this method makes explicit checks
 * if the view hierarchy has not changed in another iOS version.
 */
- (UIWindow *)keyboardWindow {
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    if ([allWindows count] < 2) return nil;
    
    UIWindow *keyboardWindow = [allWindows objectAtIndex:1];
    NSString *specificWindowClassName = NSStringFromClass([keyboardWindow class]);
    if (![specificWindowClassName isEqualToString:@"UITextEffectsWindow"]) {
        return nil;
    }
    
    return keyboardWindow;
}

/*
 * Fetches the keyboard view, this method makes explicit checks
 * if the view hierarchy has not changed in another iOS version.
 */
- (UIView *)keyboardView {
    UIWindow *keyboardWindow = [self keyboardWindow];
    if (!keyboardWindow) return nil;
    
    NSArray *keyboardWindowSubviews = [keyboardWindow subviews];
    if ([keyboardWindowSubviews count] == 0) return nil;
    
    UIView *keyboardView = [keyboardWindowSubviews objectAtIndex:0];
    NSString *specificViewClassName = NSStringFromClass([keyboardView class]);
    if (![specificViewClassName isEqualToString:@"UIPeripheralHostView"]) {
        return nil;
    }

    return keyboardView;
}

# pragma mark - gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
