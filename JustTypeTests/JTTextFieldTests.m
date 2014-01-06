//
//  JTTextFieldTests.m
//  JustType
//
//  Created by Alexander Koglin on 05.01.14.
//
//

#import <XCTest/XCTest.h>
#import "JTTextField.h"
#import "JTTextField+TestsPrivate.h"
#import "JTTextFieldMediatorDelegate.h"

@interface JTTextFieldTests : XCTestCase

@end

@implementation JTTextFieldTests

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

- (void)testSetupOfTextField {
    JTTextField *textField = [[JTTextField alloc] initWithFrame:CGRectZero];
    
    // has textController
    XCTAssertNotNil(textField.textController, @"should have a text controller");
    
    // has mediator delegate
    XCTAssertNotNil(textField.mediatorDelegate, @"textField should intercept its delegate calls");
    
    // returns correct textContent
    XCTAssertNotNil(textField.textContent, @"The textContent delegate method should refer to the empty text of the element");
    textField.text = @"Bla";
    XCTAssertEqualObjects(textField.text, textField.textContent, @"The textContent should have been changed");
    
    // has feature switches turned on
    XCTAssertTrue(textField.isSyntaxHighlightingUsed, @"syntax highlighting should be switched on initially");
    XCTAssertTrue(textField.isSyntaxCompletionUsed, @"syntax completion should be switched on initially");
    
    // has correct initial colors set
    XCTAssertEqualObjects(textField.unhighlightedColor, [UIColor blackColor], @"The textFields default color should be black");
    XCTAssertEqualObjects(textField.highlightedColor, [UIColor grayColor], @"The textFields highlighted word color should be gray");
}

- (void)testHighlightingOfTextField {
    JTTextField *textField = [[JTTextField alloc] initWithFrame:CGRectZero];

    // set the textContent
    textField.text = @"Hallo du!";

    // after replacing highlighting range
    [textField replaceHighlightingWithRange:NSMakeRange(0, 5)];
    
    // still returns right textContent
    XCTAssertEqualObjects(textField.text, textField.textContent, @"The text content should be unchanged after replacing highlighting");
    
    NSRange range;
    [textField.attributedText attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
    XCTAssertEqual((NSInteger)range.length, 5, @"The foreground color should be changed from index 0 to 5");
}

@end
