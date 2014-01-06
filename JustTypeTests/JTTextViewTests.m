//
//  JTTextViewTests.m
//  JustType
//
//  Created by Alexander Koglin on 05.01.14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "JTTextView.h"
#import "JTTextView+TestsPrivate.h"

@interface JTTextViewTests : XCTestCase

@end

@implementation JTTextViewTests

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

- (void)testSetupOfTextView {
    JTTextView *textView = [[JTTextView alloc] initWithFrame:CGRectZero];
    
    // has textController
    XCTAssertNotNil(textView.textController, @"should have a text controller");
    
    // has mediator delegate
    XCTAssertNotNil(textView.mediatorDelegate, @"textView should intercept its delegate calls");
    
    // returns correct textContent
    XCTAssertNotNil(textView.textContent, @"The textContent delegate method should refer to the empty text of the element");
    textView.text = @"Bla";
    XCTAssertEqualObjects(textView.text, textView.textContent, @"The textContent should have been changed");
    
    // has feature switches turned on
    XCTAssertTrue(textView.isSyntaxHighlightingUsed, @"syntax highlighting should be switched on initially");
    XCTAssertTrue(textView.isSyntaxCompletionUsed, @"syntax completion should be switched on initially");
    
    XCTAssertNotNil(textView.highlightView, @"a highlightview should be initially set");
}

- (void)testCustomHighlightView {
    JTTextView *textView = [[JTTextView alloc] initWithFrame:CGRectZero];
    textView.text = @"Hallo Welt";
    
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *highlightMock = [OCMockObject partialMockForObject:highlightView];
    textView.highlightView = highlightMock;
    
    [[(id)highlightMock expect] setNeedsDisplay];
    
    [textView replaceHighlightingWithRange:NSMakeRange(0, 4)];
    
    [(id)highlightMock verify];
}

@end
