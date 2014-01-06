//
//  JTTextControllerTests.m
//  JustType
//
//  Created by Alexander Koglin on 05.01.14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "JTTextController.h"
#import "JTTextController+TestsPrivate.h"

@interface JTTestTextControllerDelegate : UITextView<UITextInput, JTTextControllerDelegate>
@end


@interface JTTextControllerTests : XCTestCase

@end

@implementation JTTextControllerTests

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

- (JTTextController *)mockedTextController {
    JTTextController *textController = [[JTTextController alloc] init];
    return [OCMockObject partialMockForObject:textController];
}

- (JTTestTextControllerDelegate *)mockedTextControllerDelegate {
    JTTestTextControllerDelegate *textControllerDelegate = [[JTTestTextControllerDelegate alloc] init];
    return [OCMockObject partialMockForObject:textControllerDelegate];
}

- (void)testInitialSetup {
    JTTextController *textController = [self mockedTextController];
    
    XCTAssertEqual([textController.syntaxWordClassNames count], (NSUInteger)2, @"There should be two possible syntax word classes for now");
    XCTAssertTrue(textController.useSyntaxCompletion, @"syntax completion should be turned on initially");
}

- (void)testMoveToPreviousWord {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTestTextControllerDelegate *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a text";
    testTextDelegate.selectedRange = NSMakeRange(5, 0);
    
    // do the testing
    [textController moveToPreviousWord];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)0, @"The selection should have been moved to position 0");
}

- (void)testMoveToNextWord {
    
}

- (void)testMoveToPreviousLetter {
    
}

- (void)testMoveToNextLetter {
    
}

- (void)testSelectPreviousSuggestion {
    
}

- (void)testSelectNextSuggestion {
    
}

- (void)testSelectSuggestionByIndex {
    
}

@end
