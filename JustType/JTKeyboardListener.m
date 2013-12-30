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

#define SWIPE_PIXEL_THRESHOLD 40.0
#define SWIPE_LONGSWIPE_WIDTH 100.0
#define SAMPLE_TIME_SECS 0.2

@interface JTKeyboardListener ()

@property (nonatomic, readonly) UIWindow *mainWindow;
@property (nonatomic, readonly) UIWindow *keyboardWindow;
@property (nonatomic, readonly) UIWindow *keyboardView;

@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint gestureStartingPoint;
@property (nonatomic, assign) CGPoint gestureMovementPoint;
@property (nonatomic, assign) NSTimeInterval currentSampleInterval;
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

@end


@implementation JTKeyboardListener 
@synthesize panGesture = _panGesture;
@synthesize keyboardOverlayView = _keyboardOverlayView;
@synthesize gestureStartingPoint = _gestureStartingPoint;
@synthesize gestureMovementPoint = _gestureMovementPoint;
@synthesize currentSampleInterval = _currentSampleInterval;
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
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
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
    
    NSLog(@"gesture pan");
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.gestureStartingPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
        self.gestureMovementPoint = self.gestureStartingPoint;
        self.panGestureInProgress = YES;
        [self performSelector:@selector(checkGestureResult) withObject:nil afterDelay:SAMPLE_TIME_SECS];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        self.gestureMovementPoint = [gestureRecognizer locationInView:self.keyboardOverlayView];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        self.panGestureInProgress = NO;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
        [self stopPollingAndCleanGesture];
    }
}

- (void)checkGestureResult {

    CGPoint diffPoint = CGPointMake(self.gestureMovementPoint.x - self.gestureStartingPoint.x,
                                    self.gestureMovementPoint.y - self.gestureStartingPoint.y);
    CGPoint absDiffPoint = CGPointMake(ABS(diffPoint.x), ABS(diffPoint.y));
    
    if (absDiffPoint.x > SWIPE_PIXEL_THRESHOLD || absDiffPoint.y > SWIPE_PIXEL_THRESHOLD)  {
                
        if (absDiffPoint.x >= absDiffPoint.y) {
            if (diffPoint.x >=0) {
                if (absDiffPoint.x < SWIPE_LONGSWIPE_WIDTH) {
                    self.lastSwipeDirection = JTKeyboardGestureSwipeRightShort;
                } else {
                    self.lastSwipeDirection = JTKeyboardGestureSwipeRightLong;
                }
            } else {
                if (absDiffPoint.x < SWIPE_LONGSWIPE_WIDTH) {
                    self.lastSwipeDirection = JTKeyboardGestureSwipeLeftShort;
                } else {
                    self.lastSwipeDirection = JTKeyboardGestureSwipeLeftLong;
                }
            }
        } else {
            if (diffPoint.y >= 0) {
                self.lastSwipeDirection = JTKeyboardGestureSwipeUp;
            } else {
                self.lastSwipeDirection = JTKeyboardGestureSwipeDown;
            }
        }
        
        [self sendNotificationForSwipeDirection:self.lastSwipeDirection];
        [self doPolling];
        
    } else {
        
        [self stopPollingAndCleanGesture];
        
    }
}

- (void)doPolling {
    if (self.panGestureInProgress) {
        [self sendNotificationForLastSwipeDirection];
        [self performSelector:@selector(doPolling) withObject:nil afterDelay:0.2];
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

    [self sendNotificationForSwipeDirection:swipeDirection];
}

- (void)sendNotificationForSwipeDirection:(NSString *)swipeDirection {
    [[NSNotificationCenter defaultCenter] postNotificationName:swipeDirection object:self];
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

# pragma mark - gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
