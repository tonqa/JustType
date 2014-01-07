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
#import "JTTextView.h"
#import "JTSyntaxWord.h"

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

- (JTTextView *)mockedTextControllerDelegate {
    JTTextView *textControllerDelegate = [[JTTextView alloc] init];
    textControllerDelegate = [OCMockObject partialMockForObject:textControllerDelegate];
    [[[(id)textControllerDelegate stub] andReturnValue:[NSNumber numberWithBool:YES]] isFirstResponder];
    [[[(id)textControllerDelegate stub] andReturn:[self mockedTextInputMode]] textInputMode];
    return textControllerDelegate;
}

- (UITextInputMode *)mockedTextInputMode {
    UITextInputMode *textInputMode = [OCMockObject mockForClass:[UITextInputMode class]];
    
    [[[(id)textInputMode stub] andReturn:@"en-US"] primaryLanguage];
    return textInputMode;
}

- (void)testInitialSetup {
    JTTextController *textController = [self mockedTextController];
    
    XCTAssertEqual([textController.syntaxWordClassNames count], (NSUInteger)2, @"There should be two possible syntax word classes for now");
    XCTAssertTrue(textController.useSyntaxCompletion, @"syntax completion should be turned on initially");
}

- (void)testMoveToPreviousWordInBetweenText {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a text";
    testTextDelegate.selectedRange = NSMakeRange(5, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToPreviousWord];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)0, @"The selection should have been moved to position 0");
}

- (void)testMoveToPreviousWordAtBeginningOfText {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a text";
    testTextDelegate.selectedRange = NSMakeRange(0, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToPreviousWord];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)0, @"The selection should have been staying at position 0");
}

- (void)testMoveToNextWordInBetweenTextAtBeginningOfWord {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a text";
    testTextDelegate.selectedRange = NSMakeRange(5, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToNextWord];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)7, @"The selection should have been moved to end of word at position 7");
}

- (void)testMoveToNextWordForCombinedWords {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"With love; with joy.";
    testTextDelegate.selectedRange = NSMakeRange(6, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToNextWord];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)9, @"The selection should have been moved between 'love' and ';' at position 9");
}

- (void)testMoveToPreviousLetterInBetweenText {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"With love; with joy.";
    testTextDelegate.selectedRange = NSMakeRange(6, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToPreviousLetter];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)5, @"The selection should have been moved one letter to the left");
}

- (void)testMoveToPreviousLetterAtBeginningOfText {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"With love; with joy.";
    testTextDelegate.selectedRange = NSMakeRange(0, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToPreviousLetter];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)0, @"The selection should have stayed at position 0");
}

- (void)testMoveToNextLetter {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a test.";
    testTextDelegate.selectedRange = NSMakeRange(6, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToNextLetter];
    
    XCTAssertEqual(testTextDelegate.selectedRange.location, (NSUInteger)7, @"The selection should have moved one to the right");
}

- (void)testAddingSpaceAtEndOfTextWhenMovingToNextWord {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a test";
    testTextDelegate.selectedRange = NSMakeRange(testTextDelegate.text.length, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToNextWord];
    
    XCTAssertEqualObjects(testTextDelegate.text, @"This is a test ", @"space should have been added to the text");
    XCTAssertEqual(testTextDelegate.selectedRange.location, testTextDelegate.text.length, @"The selection should be at the end");
}

- (void)testAddingDotAtEndOfTextWhenMovingToNextWord {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a test ";
    testTextDelegate.selectedRange = NSMakeRange(testTextDelegate.text.length, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    [textController moveToNextWord];
    
    XCTAssertEqualObjects(testTextDelegate.text, @"This is a test. ", @"space should have been added to the text");
    XCTAssertEqual(testTextDelegate.selectedRange.location, testTextDelegate.text.length, @"The selection should be at the end");
}

- (void)testSelectNextSuggestion {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a test ";
    testTextDelegate.selectedRange = NSMakeRange(0, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];

    id<JTSyntaxWord> syntaxWord = [textController selectedSyntaxWord];
    XCTAssertEqualObjects(syntaxWord.text, @"This", @"The right syntax word should have been selected");
    XCTAssertEqual([textController selectedSyntaxWordRange].location, (NSUInteger)0, @"The selected word range should begin with 0");
    XCTAssertEqual([textController selectedSyntaxWordRange].length, [syntaxWord.text length], @"The selected word range should have the text length");

    [textController selectNextSuggestion];
    
    NSString *firstSuggestion = [[syntaxWord allSuggestions] objectAtIndex:0];
    XCTAssertTrue([testTextDelegate.text hasPrefix:firstSuggestion], @"The text should begin with the first suggestion now");
    XCTAssertEqual(testTextDelegate.selectedRange.location, firstSuggestion.length, @"The selection should be at the end");
    XCTAssertEqual([textController selectedSyntaxWordRange].location, (NSUInteger)0, @"The selected word range should begin with 0");
    XCTAssertEqual([textController selectedSyntaxWordRange].length, [firstSuggestion length], @"The selected word range should have the next suggestion text length");
}

- (void)testSelectPreviousSuggestion {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a test ";
    testTextDelegate.selectedRange = NSMakeRange(0, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];    
    id<JTSyntaxWord> syntaxWord = [textController selectedSyntaxWord];
    
    [textController selectPreviousSuggestion];
    
    NSString *previousSuggestion = [[syntaxWord allSuggestions] objectAtIndex:[[syntaxWord allSuggestions] count]-1];
    XCTAssertTrue([testTextDelegate.text hasPrefix:previousSuggestion], @"The text should begin with the previous suggestion now");
    XCTAssertEqual(testTextDelegate.selectedRange.location, previousSuggestion.length, @"The selection should be at the end of the word");
    XCTAssertEqual([textController selectedSyntaxWordRange].location, (NSUInteger)0, @"The selected word range should begin with 0");
    XCTAssertEqual([textController selectedSyntaxWordRange].length, [previousSuggestion length], @"The selected word range should have the previous suggestion text length");
}

- (void)testSelectSuggestionByIndex {
    // setup of the mock objects
    JTTextController *textController = [self mockedTextController];
    JTTextView *testTextDelegate = [self mockedTextControllerDelegate];
    textController.delegate = testTextDelegate;
    
    // set the text and selection
    testTextDelegate.text = @"This is a test ";
    testTextDelegate.selectedRange = NSMakeRange(0, 0);
    
    // do the testing
    [textController computeSyntaxWordWithForcedRecomputation:YES];
    id<JTSyntaxWord> syntaxWord = [textController selectedSyntaxWord];
    
    // we get a random selected index via modulo (to be safe)
    NSUInteger selectedIndex = 3 % [[syntaxWord allSuggestions] count];
    NSString *selectedSuggestion = [[syntaxWord allSuggestions] objectAtIndex:selectedIndex];
    [textController selectSuggestionByIndex:selectedIndex];
    
    XCTAssertTrue([testTextDelegate.text hasPrefix:selectedSuggestion], @"The text should begin with the selected suggestion now");
    XCTAssertEqual(testTextDelegate.selectedRange.location, selectedSuggestion.length, @"The selection should be at the end of the word");
    XCTAssertEqual([textController selectedSyntaxWordRange].location, (NSUInteger)0, @"The selected word range should begin with 0");
    XCTAssertEqual([textController selectedSyntaxWordRange].length, [selectedSuggestion length], @"The selected word range should have the selected suggestion text length");
}

@end
