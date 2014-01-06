//
//  JTTextController+TestsPrivate.h
//  JustType
//
//  Created by Alexander Koglin on 06.01.14.
//
//

#import "JTTextController.h"

@interface JTTextController (TestsPrivate)

@property (nonatomic, retain) NSArray *syntaxWordClassNames;
@property (nonatomic, assign) NSRange selectedSyntaxWordRange;
@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;
@property (nonatomic, assign) NSInteger selectedSyntaxWordSuggestionIndex;
@property (nonatomic, assign) BOOL isIgnoringSelectionUpdates;
@property (nonatomic, assign) BOOL isIgnoringChangeUpdates;

- (BOOL)getRangeOfSelectedWord:(NSRange *)range atIndex:(NSInteger)index;
- (BOOL)getRangeOfNextWord:(NSRange *)range fromIndex:(NSInteger)index;
- (BOOL)doesTextInRangeComplyToSyntaxWord:(NSRange)range;
- (id<JTSyntaxWord>)syntaxWordForTextInRange:(NSRange)range;
- (void)computeSyntaxWordWithForcedRecomputation:(BOOL)enforced;
- (BOOL)getSelectedIndex:(NSInteger *)selectedIndex;
- (BOOL)getSelectedRange:(NSRange *)selectedIndex;
- (void)moveSelectionToIndex:(NSInteger)newIndex;
- (void)selectNextSuggestionInForwardDirection:(BOOL)forward;
- (void)selectSuggestionByIndex:(NSInteger)index;
- (void)nextSuggestionInForwardDirection:(BOOL)forward word:(NSString **)word index:(NSInteger *)currentIndex;
- (void)replaceRange:(NSRange)range withText:(NSString *)text;
- (UITextRange *)textRangeFromRange:(NSRange)range;
- (void)selectNextSeperatorForEndOfDocument;
- (void)trimDownLastWhitespacesToOneWhitespace;
- (void)postDidProcessNotificationForDirection:(NSString *)direction;
- (BOOL)findEndIndexOfSelectedBlock:(NSInteger *)index selectedIndex:(NSInteger)selectedIndex endIndexOfDoc:(NSInteger)indexOfLastLetterOfDoc;
- (NSInteger)findStartIndexOfSelectedBlockWithEndIndex:(NSInteger)indexOfLastLetterOfBlock;
- (BOOL)updateRange:(NSRange *)range withSelectedIndex:(NSInteger)selectedIndex
  startIndexOfBlock:(NSInteger)indexOfFirstLetterOfBlock
           endIndex:(NSInteger)indexOfLastLetterOfBlock;
- (NSInteger)endIndexOfDocument;

@end
