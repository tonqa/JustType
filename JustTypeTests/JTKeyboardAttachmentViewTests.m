//
//  JTKeyboardAttachmentViewTests.m
//  JustType
//
//  Created by Alexander Koglin on 05.01.14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "JTSyntaxWord.h"
#import "JTSyntaxLinguisticWord.h"
#import "JTSyntaxSeperatorWord.h"
#import "JTKeyboardAttachmentView.h"
#import "JTKeyboardAttachmentView+TestsPrivate.h"

@interface JTKeyboardAttachmentViewTests : XCTestCase

@end

@implementation JTKeyboardAttachmentViewTests

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

- (UITextInputMode *)mockedTextInputMode {
    UITextInputMode *textInputMode = [OCMockObject mockForClass:[UITextInputMode class]];
    
    [[[(id)textInputMode stub] andReturn:@"US-us"] primaryLanguage];
    return textInputMode;
}

- (void)testCreationWithLinguisticSyntaxWord {
    NSString *textualWord = @"testimonial";
    
    JTSyntaxLinguisticWord *linguisticWord = [[JTSyntaxLinguisticWord alloc] initWithText:textualWord inRange:NSMakeRange(0, textualWord.length) useSuggestions:YES textInputMode:[self mockedTextInputMode]];
    
    JTKeyboardAttachmentView *attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:CGRectMake(0, 0, 1000, 20)];
    attachmentView.selectedSyntaxWord = linguisticWord;
    
    XCTAssertEqual(attachmentView.highlightedIndex, -1,
                   @"There should not be any highlighting initially");
    XCTAssertEqual([attachmentView.buttons count],
                   [linguisticWord.allSuggestions count]+1,
                   @"There should have been created the right amount of buttons");
}

- (void)testCreationWithSeperationSyntaxWord {
    NSString *textualWord = @"...";
    
    JTSyntaxSeperatorWord *seperatorWord = [[JTSyntaxSeperatorWord alloc] initWithText:textualWord inRange:NSMakeRange(0, textualWord.length) useSuggestions:YES textInputMode:[self mockedTextInputMode]];
    
    JTKeyboardAttachmentView *attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:CGRectMake(0, 0, 1000, 20)];
    attachmentView.selectedSyntaxWord = seperatorWord;
    
    XCTAssertEqual(attachmentView.highlightedIndex, -1,
                   @"There should not be any highlighting initially");
    XCTAssertEqual([attachmentView.buttons count],
                   [seperatorWord.allSuggestions count]+1,
                   @"There should have been created the right amount of buttons");
}

- (void)testNumberOfSuggestionsInSyntaxWord {
    NSString *textualWord = @"...";
    
    JTSyntaxSeperatorWord *seperatorWord = [[JTSyntaxSeperatorWord alloc] initWithText:textualWord inRange:NSMakeRange(0, textualWord.length) useSuggestions:YES textInputMode:[self mockedTextInputMode]];
    
    XCTAssertEqual([seperatorWord.allSuggestions count],
                   [[JTSyntaxSeperatorWord possibleSuggestions] count],
                   @"The suggestions of a non-trivial seperator word should be excactly those returned by 'possibleSuggestions'.");
}

@end
