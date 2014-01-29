//
//  JTKeyboardListenerTests.m
//  JustType
//
//  Created by Alexander Koglin on 05.01.14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "JTKeyboardHeaders.h"
#import "JTKeyboardListener.h"
#import "JTKeyboardListener+TestsPrivate.h"

@interface JTKeyboardListenerTests : XCTestCase

@end

@implementation JTKeyboardListenerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (JTKeyboardListener *)mockedKeyboardListener {
    JTKeyboardListener *keyboardListener = [[JTKeyboardListener alloc] init];
    return [OCMockObject partialMockForObject:keyboardListener];
}

- (void)testRecomputeSwipeHorizontalSucceeds
{
    /*
     Initial setup
     */
    JTKeyboardListener *mock = [self mockedKeyboardListener];
    
    mock.gestureStartingPoint = CGPointMake(200, 200);

    XCTAssertNil(mock.lastSwipeGestureType, @"Last swipe direction should be nil initially");
    
    /*
     Test if short right gesture movement ist recognized
     */
    mock.gestureMovementPoint = CGPointMake(300, 200);
    
    [mock recomputeSwipe];
    
    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeRightShort, @"Short right keyboard gesture should have been recognized");

    /*
     Test if long right gesture movement ist recognized
     */
    mock.gestureMovementPoint = CGPointMake(400, 200);

    [mock recomputeSwipe];

    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeRightLong, @"Long right keyboard gesture should have been recognized");

    /*
     Test if short left gesture movement ist recognized
     */
    mock.gestureMovementPoint = CGPointMake(100, 200);
    
    [mock recomputeSwipe];
    
    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeLeftShort, @"Short left keyboard gesture should have been recognized");

    /*
     Test if long left gesture movement ist recognized
     */
    mock.gestureMovementPoint = CGPointMake(0, 200);
    
    [mock recomputeSwipe];
    
    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeLeftLong, @"Long left keyboard gesture should have been recognized");
}

- (void)testRecomputeSwipeAndCleanup {
    /*
     Initial setup
     */
    JTKeyboardListener *mock = [self mockedKeyboardListener];
    
    mock.gestureStartingPoint = CGPointMake(200, 200);
    mock.gestureMovementPoint = CGPointMake(300, 200);

    [mock recomputeSwipe];

    XCTAssertNotNil(mock.lastSwipeGestureType, @"Swipe direction should have been set");

    /*
     Test if gesture movement is properly reset
     */
    [mock stopPollingAndCleanGesture];
    
    XCTAssertNil(mock.lastSwipeGestureType, @"Last swipe direction should be nilled again");
}

- (void)testRecomputeSwipeVerticalFails
{
    /*
     Initial setup
     */
    JTKeyboardListener *mock = [self mockedKeyboardListener];
    
    mock.gestureStartingPoint = CGPointMake(200, 200);
    
    XCTAssertNil(mock.lastSwipeGestureType, @"Last swipe direction should be nil initially");
    
    /*
     Test if short right gesture movement ist recognized
     */
    mock.gestureMovementPoint = CGPointMake(250, 200);
    
    [mock recomputeSwipe];
    
    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeRightShort, @"Short right keyboard gesture should have been recognized");
    
    /*
     Test if up gesture movement is not possible any more during one gesture
     */
    mock.gestureMovementPoint = CGPointMake(200, 0);
    
    [mock recomputeSwipe];
    
    XCTAssertNotEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeUp, @"Swipe up keyboard gesture should not be possible during horizontal movement");
    
    /*
     Test if down gesture movement is not possible any more during one gesture
     */
    mock.gestureMovementPoint = CGPointMake(200, 400);
    
    [mock recomputeSwipe];
    
    XCTAssertNotEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeDown, @"Swipe down keyboard gesture should not be possible during horizontal movement");
}

- (void)testRecomputeSwipeUpSucceeds
{
    /*
     Initial setup
     */
    JTKeyboardListener *mock = [self mockedKeyboardListener];
    
    mock.gestureStartingPoint = CGPointMake(200, 200);
    
    XCTAssertNil(mock.lastSwipeGestureType, @"Last swipe direction should be nil initially");
    
    /*
     Test if up gesture movement is recognized
     */
    mock.gestureMovementPoint = CGPointMake(200, 0);
    
    [mock recomputeSwipe];
    
    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeUp, @"Up keyboard gesture should have been recognized");
}

- (void)testRecomputeSwipeDownSucceeds
{
    /*
     Initial setup
     */
    JTKeyboardListener *mock = [self mockedKeyboardListener];
    
    mock.gestureStartingPoint = CGPointMake(200, 200);
    
    XCTAssertNil(mock.lastSwipeGestureType, @"Last swipe direction should be nil initially");
    
    /*
     Test if down gesture movement is recognized
     */
    mock.gestureMovementPoint = CGPointMake(200, 400);

    [mock recomputeSwipe];

    XCTAssertEqualObjects(mock.lastSwipeGestureType, JTKeyboardGestureSwipeDown, @"Down keyboard gesture should have been recognized");
}

- (void)testSendNotificationForLastSwipeGesture {
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    JTKeyboardListener *mock = [self mockedKeyboardListener];
    NSString *swipeDirection = JTKeyboardGestureSwipeLeftLong;
    mock.lastSwipeGestureType = swipeDirection;
    
    /*
     set up observer mock
     */
    id observerMock = [OCMockObject observerMock];
    [notifCenter addMockObserver:observerMock name:JTNotificationTextControllerDidRecognizeGesture object:nil];
    [[observerMock expect] notificationWithName:JTNotificationTextControllerDidRecognizeGesture object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        return [[userInfo objectForKey:JTNotificationKeyDirection] isEqualToString:swipeDirection];
    }]];
    
    /*
     call the method sending the notifcation
     */
    [mock sendNotificationForLastSwipeGesture];
    
    /*
     verify notification
     */
    [notifCenter removeObserver:observerMock];
    [observerMock verify];
}

@end
