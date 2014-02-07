//
//  JTKeyboardListener.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTKeyboardListener.h"
#import "JTKeyboardOverlayView.h"
#import "JTKeyboardGestureRecognizer.h"
#import "JTKeyboardHeaders.h"

enum JTKeyboardSwipeDirection {
    JTKeyboardSwipeDirectionNone = 0,
    JTKeyboardSwipeDirectionHorizontal = 1,
    JTKeyboardSwipeDirectionVertical = 2
    };

NSString * const JTKeyboardGestureSwipeLeftLong     = @"JTKeyboardGestureSwipeLeftLong";
NSString * const JTKeyboardGestureSwipeRightLong    = @"JTKeyboardGestureSwipeRightLong";
NSString * const JTKeyboardGestureSwipeLeftShort    = @"JTKeyboardGestureSwipeLeftShort";
NSString * const JTKeyboardGestureSwipeRightShort   = @"JTKeyboardGestureSwipeRightShort";
NSString * const JTKeyboardGestureSwipeUp           = @"JTKeyboardGestureSwipeUp";
NSString * const JTKeyboardGestureSwipeDown         = @"JTKeyboardGestureSwipeDown";

NSString * const JTKeyboardActionCapitalized        = @"JTKeyboardActionCapitalized";
NSString * const JTKeyboardActionLowercased         = @"JTKeyboardActionLowercased";

#define SWIPE_SHORTSLOWSWIPE_WIDTH 45.0
#define SWIPE_SHORTMEDIUMSWIPE_WIDTH 75.0
#define SWIPE_SHORTFASTSWIPE_WIDTH 100.0
#define SWIPE_LONGSLOWSWIPE_WIDTH 120.0
#define SWIPE_LONGMEDIUMSWIPE_WIDTH 135.0
#define SWIPE_LONGFASTSWIPE_WIDTH 1000.0 // everything else

#define SAMPLE_TIME_SECS_INITIAL 0.6
#define SAMPLE_TIME_SECS_MAX 0.4
#define SAMPLE_TIME_SECS_MIDDLE 0.2
#define SAMPLE_TIME_SECS_MIN 0.1

@interface JTKeyboardListener ()

@property (nonatomic, readonly) UIWindow *mainWindow;
@property (nonatomic, readonly) UIWindow *keyboardWindow;
@property (nonatomic, readonly) UIWindow *keyboardView;

@property (nonatomic, retain) UIGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint gestureStartingPoint;
@property (nonatomic, assign) CGPoint gestureMovementPoint;
@property (nonatomic, assign) enum JTKeyboardSwipeDirection lastSwipeDirection;
@property (nonatomic, retain) NSString *lastSwipeGestureType;
@property (nonatomic, assign) BOOL panGestureInProgress;
@property (nonatomic, assign) CGFloat pollingTime;
@property (nonatomic, assign) NSUInteger numberOfEvents;

@property (nonatomic, retain) JTKeyboardOverlayView *keyboardOverlayView;
@property (nonatomic, assign, getter = areGesturesEnabled) BOOL enableGestures;

- (void)cleanupViewsAndGestures;
- (void)storeStartingPointWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)sendNotificationForLastSwipeGesture;
- (void)checkGestureResult;
- (void)doPolling;
- (void)stopPollingAndCleanGesture;
- (void)recomputeSwipe;
- (BOOL)keyboardIsAvailable;

@end


@implementation JTKeyboardListener 
@synthesize panGesture = _panGesture;
@synthesize keyboardOverlayView = _keyboardOverlayView;
@synthesize gestureStartingPoint = _gestureStartingPoint;
@synthesize gestureMovementPoint = _gestureMovementPoint;
@synthesize lastSwipeDirection = _lastSwipeDirection;
@synthesize lastSwipeGestureType = _lastSwipeGestureType;
@synthesize panGestureInProgress = _panGestureInProgress;
@synthesize enableVisualHelp = _enableVisualHelp;
@synthesize enableGestures = _enableGestures;
@synthesize pollingTime = _pollingTime;

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
        self.enableVisualHelp = YES;
        [self stopPollingAndCleanGesture];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textControllerDidProcessGesture:)
                                                     name:JTNotificationTextControllerDidProcessGesture object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textControllerDidExecuteAction:)
                                                     name:JTNotificationTextControllerDidExecuteAction object:nil];
        
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
    
    [self setEnableGestures:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self cleanupViewsAndGestures];
}

- (void)cleanupViewsAndGestures {
    // remove all the views and gestures
    [self.keyboardOverlayView removeFromSuperview];
    self.keyboardOverlayView = nil;
    
    [self setEnableGestures:NO];
}

# pragma mark - internal notifications
- (void)textControllerDidProcessGesture:(NSNotification *)notification {
    if (self.isVisualHelpEnabled) {
        
        if (self.numberOfEvents == 0) {
            [self.keyboardOverlayView draggingBeganFromPoint:self.gestureStartingPoint];
        }
        
        BOOL isHorizontalSwipe = (self.lastSwipeDirection == JTKeyboardSwipeDirectionHorizontal);
        [self.keyboardOverlayView visualizeDragFromPoint:self.gestureStartingPoint toPoint:self.gestureMovementPoint horizontal:isHorizontalSwipe];
    }
    self.numberOfEvents++;
}

- (void)textControllerDidExecuteAction:(NSNotification *)notification {
    NSString *action = [notification.userInfo objectForKey:JTNotificationKeyAction];
    [self.keyboardOverlayView visualizeDirection:action];
}

# pragma mark - Gesture recognizers
- (void)panned:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.panGestureInProgress = YES;
        self.gestureStartingPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
        self.gestureMovementPoint = self.gestureStartingPoint;
        
        // we give it a small time for deciding between a short and a long swipe
        [self performSelector:@selector(checkGestureResult) withObject:nil afterDelay:SAMPLE_TIME_SECS_MIN];

    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        self.gestureMovementPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
        self.panGestureInProgress = NO;

    }
}

- (void)checkGestureResult {

    [self recomputeSwipe];

    // now after the first swipe we wait a quite high amount of time until we begin the high-density polling for the 'long-duration swipe'.
    [self performSelector:@selector(doPolling) withObject:nil afterDelay:SAMPLE_TIME_SECS_INITIAL];
}

- (void)doPolling {
    if (self.panGestureInProgress) {
        [self recomputeSwipe];
        [self performSelector:@selector(doPolling) withObject:nil afterDelay:self.pollingTime];
    } else {
        [self stopPollingAndCleanGesture];
        [self.keyboardOverlayView draggingStopped];
    }
}

- (void)stopPollingAndCleanGesture {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    self.gestureStartingPoint = CGPointZero;
    self.gestureMovementPoint = CGPointZero;
    self.lastSwipeGestureType = nil;
    self.lastSwipeDirection = JTKeyboardSwipeDirectionNone;
    self.pollingTime = SAMPLE_TIME_SECS_MIDDLE;
    self.panGestureInProgress = NO;
    self.numberOfEvents = 0;
}

- (void)storeStartingPointWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // store the starting point
    self.gestureStartingPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
}

- (void)recomputeSwipe {
    
    CGPoint diffPoint = CGPointMake(self.gestureMovementPoint.x - self.gestureStartingPoint.x,
                                    self.gestureMovementPoint.y - self.gestureStartingPoint.y);

    if (self.lastSwipeDirection == JTKeyboardSwipeDirectionHorizontal) {
        [self determineHorizontalSwipeGestureWithDiff:diffPoint];
        [self sendNotificationForLastSwipeGesture];

    } else if (self.lastSwipeDirection == JTKeyboardSwipeDirectionVertical) {
        [self determineVerticalSwipeGestureWithDiff:diffPoint];
        [self sendNotificationForLastSwipeGesture];
        
    } else if (self.lastSwipeDirection == JTKeyboardSwipeDirectionNone) {
        [self determineAllSwipeGestureDirectionsWithDiff:diffPoint];
        [self sendNotificationForLastSwipeGesture];

    }

}

- (void)determineAllSwipeGestureDirectionsWithDiff:(CGPoint)diffPoint {
    CGPoint absDiffPoint = CGPointMake(ABS(diffPoint.x), ABS(diffPoint.y));
    
    if (absDiffPoint.x >= absDiffPoint.y) {
        self.lastSwipeDirection = JTKeyboardSwipeDirectionHorizontal;
        [self determineHorizontalSwipeGestureWithDiff:diffPoint];
        
    } else {
        self.lastSwipeDirection = JTKeyboardSwipeDirectionVertical;
        [self determineVerticalSwipeGestureWithDiff:diffPoint];
    }

}

- (void)determineHorizontalSwipeGestureWithDiff:(CGPoint)diffPoint {
    if (diffPoint.x < 0) {
        CGFloat x = -diffPoint.x;
        if (x <= SWIPE_SHORTSLOWSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeLeftShort;
            self.pollingTime = SAMPLE_TIME_SECS_MAX;

        } else if (x <= SWIPE_SHORTMEDIUMSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeLeftShort;
            self.pollingTime = SAMPLE_TIME_SECS_MIDDLE;

        } else if (x <= SWIPE_SHORTFASTSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeLeftShort;
            self.pollingTime = SAMPLE_TIME_SECS_MIN;

        } else if (x <= SWIPE_LONGSLOWSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeLeftLong;
            self.pollingTime = SAMPLE_TIME_SECS_MAX;

        } else if (x <= SWIPE_LONGMEDIUMSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeLeftLong;
            self.pollingTime = SAMPLE_TIME_SECS_MIDDLE;

        } else {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeLeftLong;
            self.pollingTime = SAMPLE_TIME_SECS_MIN;
        }
    } else {
        CGFloat x = diffPoint.x;
        if (x <= SWIPE_SHORTSLOWSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeRightShort;
            self.pollingTime = SAMPLE_TIME_SECS_MAX;

        } else if (x <= SWIPE_SHORTMEDIUMSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeRightShort;
            self.pollingTime = SAMPLE_TIME_SECS_MIDDLE;

        } else if (x <= SWIPE_SHORTFASTSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeRightShort;
            self.pollingTime = SAMPLE_TIME_SECS_MIN;

        } else if (x <= SWIPE_LONGSLOWSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeRightLong;
            self.pollingTime = SAMPLE_TIME_SECS_MAX;

        } else if (x <= SWIPE_LONGMEDIUMSWIPE_WIDTH) {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeRightLong;
            self.pollingTime = SAMPLE_TIME_SECS_MIDDLE;
            
        } else {
            self.lastSwipeGestureType = JTKeyboardGestureSwipeRightLong;
            self.pollingTime = SAMPLE_TIME_SECS_MIN;
        }
    }
}

- (void)determineVerticalSwipeGestureWithDiff:(CGPoint)diffPoint {
    if (diffPoint.y < 0) {
        self.lastSwipeGestureType = JTKeyboardGestureSwipeUp;
        self.pollingTime = SAMPLE_TIME_SECS_MAX;
    } else {
        self.lastSwipeGestureType = JTKeyboardGestureSwipeDown;
        self.pollingTime = SAMPLE_TIME_SECS_MAX;
    }
}

- (void)sendNotificationForLastSwipeGesture {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.lastSwipeGestureType forKey:JTNotificationKeyDirection];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JTNotificationTextControllerDidRecognizeGesture object:self userInfo:userInfo];
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

    static NSString *windowName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableString *prefix = [NSMutableString stringWithString:@"UI"];
        [prefix appendString:@"Text"@"Effects"@"Window"];
        windowName = prefix;
    });
    
    if (![specificWindowClassName isEqualToString:windowName]) {
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

    static NSString *viewName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableString *prefix = [NSMutableString stringWithString:@"UI"];
        [prefix appendString:@"Peripheral"@"Host"@"View"];
        viewName = prefix;
    });
    
    if (![specificViewClassName isEqualToString:viewName]) {
        return nil;
    }

    return keyboardView;
}

# pragma mark - gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setEnableGestures:(BOOL)enableGestures {
    if (enableGestures != _enableGestures) {
        if (enableGestures) {
            // add gesture recognizers to KeyboardView (for typing faster)
            JTKeyboardGestureRecognizer *pan = [[JTKeyboardGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
            pan.delegate = self;
            [self.keyboardView addGestureRecognizer:pan];
            self.panGesture = pan;
        } else {
            [self.panGesture.view removeGestureRecognizer:self.panGesture];
            self.panGesture = nil;
        }
        _enableGestures = enableGestures;
    }
}

# pragma mark - getters & setters
- (UIColor *)touchDownColor {
    return self.keyboardOverlayView.startCircleView.backgroundColor;
}

- (void)setTouchDownColor:(UIColor *)touchDownColor {
    self.keyboardOverlayView.startCircleView.backgroundColor = touchDownColor;
}

- (UIColor *)touchMoveColor {
    return self.keyboardOverlayView.endCircleView.backgroundColor;
}

- (void)setTouchMoveColor:(UIColor *)touchMoveColor {
    self.keyboardOverlayView.endCircleView.backgroundColor = touchMoveColor;
}

@end
