//
//  JTKeyboardListener+TestsPrivate.h
//  JustType
//
//  Created by Alexander Koglin on 05.01.14.
//
//

#import <JustType/JustType.h>

@class JTKeyboardOverlayView;
@interface JTKeyboardListener (TestsPrivate)

@property (nonatomic, readonly) UIWindow *mainWindow;
@property (nonatomic, readonly) UIWindow *keyboardWindow;
@property (nonatomic, readonly) UIWindow *keyboardView;

@property (nonatomic, retain) UIGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint gestureStartingPoint;
@property (nonatomic, assign) CGPoint gestureMovementPoint;
@property (nonatomic, assign) NSUInteger timesOccurred;
@property (nonatomic, retain) NSString *lastSwipeGestureType;
@property (nonatomic, assign) BOOL panGestureInProgress;

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