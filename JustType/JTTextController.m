//
//  JTTextController.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextController.h"
#import "JTKeyboardHeaders.h"

#import "JTSyntaxWord.h"
#import "JTSyntaxLinguisticWord.h"
#import "JTSyntaxSeperatorWord.h"

#define SYNTAX_COMPLETION_WHEN_SWIPING_RIGHT 0

@interface JTTextController ()

@property (nonatomic, readonly) NSString *textContent;
@property (nonatomic, retain) NSArray *syntaxWordClassNames;

@property (nonatomic, assign) NSRange selectedSyntaxWordRange;
@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;
@property (nonatomic, assign) NSInteger selectedSyntaxWordSuggestionIndex;
@property (nonatomic, assign) BOOL isIgnoringUpdates;

- (BOOL)getRangeOfSelectedWord:(NSRange *)range atIndex:(NSInteger)index;
- (BOOL)getRangeOfNextWord:(NSRange *)range fromIndex:(NSInteger)index;
- (BOOL)doesTextInRangeComplyToSyntaxWord:(NSRange)range;
- (id<JTSyntaxWord>)syntaxWordForTextInRange:(NSRange)range;
- (void)computeSyntaxWordWithForcedRecomputation:(BOOL)enforced;
- (BOOL)getSelectedIndex:(NSInteger *)selectedIndex;
- (BOOL)getSelectedRange:(NSRange *)selectedIndex;
- (void)moveSelectionToIndex:(NSInteger)newIndex;
- (void)selectNextSuggestionInForwardDirection:(BOOL)forward;
- (void)nextSuggestionInForwardDirection:(BOOL)forward word:(NSString **)word index:(NSInteger *)currentIndex;
- (void)replaceRange:(NSRange)range withText:(NSString *)text;
- (UITextRange *)textRangeFromRange:(NSRange)range;
- (void)selectNextSeperatorForEndOfDocument;

- (BOOL)findEndIndexOfSelectedBlock:(NSInteger *)index 
                      selectedIndex:(NSInteger)selectedIndex
                      endIndexOfDoc:(NSInteger)indexOfLastLetterOfDoc;
- (NSInteger)findStartIndexOfSelectedBlockWithEndIndex:(NSInteger)indexOfLastLetterOfBlock;
- (BOOL)updateRange:(NSRange *)range withSelectedIndex:(NSInteger)selectedIndex 
  startIndexOfBlock:(NSInteger)indexOfFirstLetterOfBlock 
           endIndex:(NSInteger)indexOfLastLetterOfBlock;
- (NSInteger)endIndexOfDocument;

@end


@implementation JTTextController
@synthesize delegate = _delegate;
@synthesize syntaxWordClassNames = _syntaxWordClassNames;
@synthesize selectedSyntaxWordRange = _selectedSyntaxWordRange;
@synthesize selectedSyntaxWord = _selectedSyntaxWord;
@synthesize selectedSyntaxWordSuggestionIndex = _selectedSyntaxWordSuggestionIndex;
@synthesize isIgnoringUpdates = _isIgnoringUpdates;
@synthesize keyboardAttachmentView = _keyboardAttachmentView;

extern NSString * const JTKeyboardGestureSwipeLeftLong;
extern NSString * const JTKeyboardGestureSwipeRightLong;
extern NSString * const JTKeyboardGestureSwipeLeftShort;
extern NSString * const JTKeyboardGestureSwipeRightShort;
extern NSString * const JTKeyboardGestureSwipeUp;
extern NSString * const JTKeyboardGestureSwipeDown;

- (id)init {
    self = [super init];
    if (self) {
        
        self.syntaxWordClassNames = [NSArray arrayWithObjects:
             NSStringFromClass([JTSyntaxLinguisticWord class]), 
             NSStringFromClass([JTSyntaxSeperatorWord class]), nil];
        
        
        NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
        [notifCenter addObserver:self selector:@selector(didSwipeLeftLong:) name:JTKeyboardGestureSwipeLeftLong object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeRightLong:) name:JTKeyboardGestureSwipeRightLong object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeLeftShort:) name:JTKeyboardGestureSwipeLeftShort object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeRightShort:) name:JTKeyboardGestureSwipeRightShort object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeUp:) name:JTKeyboardGestureSwipeUp object:nil];
        [notifCenter addObserver:self selector:@selector(didSwipeDown:) name:JTKeyboardGestureSwipeDown object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - textview / textfield notifier methods
- (void)didChangeSelection {
    if (!self.isIgnoringUpdates) {
        [self computeSyntaxWordWithForcedRecomputation:NO];
    }
}

- (void)didChangeText {
    if (!self.isIgnoringUpdates) {
        [self computeSyntaxWordWithForcedRecomputation:YES];
    }
}

#pragma mark - notification listeners
- (void)didSwipeLeftLong:(NSNotification *)notification {
    if (!self.selectedSyntaxWord) return;
        
    // first try to move to beginning of the selected word
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) return;
    
    if (selectedRange.length > 0) {
        [self moveSelectionToIndex:selectedRange.location];
        return;
    }

    NSInteger startIndexOfSelectedWord = self.selectedSyntaxWordRange.location;
    if (selectedRange.location > startIndexOfSelectedWord) {
        [self moveSelectionToIndex:startIndexOfSelectedWord];
        return;
    }
    
    // then try to move to the beginning of the word before the selected word
    if (self.selectedSyntaxWordRange.location <= 0) return;

    NSRange newWordRange;
    if (![self getRangeOfSelectedWord:&newWordRange atIndex:startIndexOfSelectedWord - 1]) return;
    if (startIndexOfSelectedWord == newWordRange.location) return;
    
    NSInteger offsetFromStartPosition = newWordRange.location;
    [self moveSelectionToIndex:offsetFromStartPosition];
}

- (void)didSwipeRightLong:(NSNotification *)notification {
    if (!self.selectedSyntaxWord) return;
    
    // first try to move to beginning of the selected word
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) return;
    
    NSInteger endIndexOfSelectedWord = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length - 1;
    if (selectedRange.location < endIndexOfSelectedWord+1) {
        [self moveSelectionToIndex:endIndexOfSelectedWord+1];
        return;
    }
    
    // then try to move to the beginning of the word before the selected word
    NSRange newWordRange;
    if (![self getRangeOfNextWord:&newWordRange fromIndex:endIndexOfSelectedWord + 1]) {
        [self selectNextSeperatorForEndOfDocument];
        return;
    }

    NSInteger offsetFromStartPosition = newWordRange.location + newWordRange.length;
    [self moveSelectionToIndex:offsetFromStartPosition];
}

- (void)didSwipeLeftShort:(NSNotification *)notification {
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) return;

    NSInteger currentIndex = selectedRange.location;
    if (currentIndex <= 0) return;
    
    [self moveSelectionToIndex:currentIndex-1];
}

- (void)didSwipeRightShort:(NSNotification *)notification {
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) return;
    
    NSInteger currentIndex = selectedRange.location+selectedRange.length;
    NSInteger maximumIndex = [self endIndexOfDocument];
    if (currentIndex >= maximumIndex) return;
    
    [self moveSelectionToIndex:currentIndex+1];
}

- (void)didSwipeUp:(NSNotification *)notification {
    [self selectNextSuggestionInForwardDirection:NO];
}

- (void)didSwipeDown:(NSNotification *)notification {
    [self selectNextSuggestionInForwardDirection:YES];
}

#pragma mark - internal methods
- (NSString *)textContent {
    return [self.delegate textContent];
}

- (BOOL)getRangeOfSelectedWord:(NSRange *)range atIndex:(NSInteger)index {
    
    NSInteger indexOfLastLetterOfDoc = [self endIndexOfDocument] - 1;

    NSInteger indexOfLastLetterOfBlock;
    if (![self findEndIndexOfSelectedBlock:&indexOfLastLetterOfBlock 
                             selectedIndex:index 
                             endIndexOfDoc:indexOfLastLetterOfDoc]) {
        return NO;
    }
        
    NSInteger indexOfFirstLetterOfBlock = [self findStartIndexOfSelectedBlockWithEndIndex:indexOfLastLetterOfBlock];
    
    return [self updateRange:range withSelectedIndex:index 
           startIndexOfBlock:indexOfFirstLetterOfBlock 
                    endIndex:indexOfLastLetterOfBlock];
}

- (BOOL)getRangeOfNextWord:(NSRange *)range fromIndex:(NSInteger)index {    
    NSInteger endIndexOfDoc = [self endIndexOfDocument];
    
    if (index >= endIndexOfDoc) return NO;
    
    NSInteger newStartIndex = index;
    while ([self.textContent characterAtIndex:newStartIndex] == ' ') {
        newStartIndex += 1;
        if (newStartIndex >= endIndexOfDoc) {
            return NO;
        }
    }
    
    return [self getRangeOfSelectedWord:range atIndex:newStartIndex];
}


- (BOOL)updateRange:(NSRange *)range withSelectedIndex:(NSInteger)selectedIndex 
  startIndexOfBlock:(NSInteger)indexOfFirstLetterOfBlock 
           endIndex:(NSInteger)indexOfLastLetterOfBlock {
    
    // go right and find the last largest matching word step-by-step
    // (until you find a word containing the current index, otherwise the last word)
    BOOL selectionIndexFound = NO; 
    NSInteger beginIndexOfWord = indexOfFirstLetterOfBlock;
    
    for (NSInteger i = indexOfFirstLetterOfBlock; i <= indexOfLastLetterOfBlock; i++) {
        
        if (i >= selectedIndex) {
            selectionIndexFound = YES;
        }

        NSInteger endIndexOfWord = i+1;
        NSRange tempWordRange = NSMakeRange(beginIndexOfWord, endIndexOfWord-beginIndexOfWord);
        
        // if word from last "beginIndexOfWord" to current "i" 
        // does not match any more open up new word (with a new "beginIndexOfWord")
        if ([self doesTextInRangeComplyToSyntaxWord:tempWordRange]) {
            *range = tempWordRange;
        } else {
            // if we meet the selection point already or come to the last word just break
            if (selectionIndexFound) break;
            
            beginIndexOfWord = i;
            *range = NSMakeRange(beginIndexOfWord, endIndexOfWord-beginIndexOfWord);
        }
    }

    return YES;
}

- (BOOL)findEndIndexOfSelectedBlock:(NSInteger *)index 
                      selectedIndex:(NSInteger)selectedIndex
                      endIndexOfDoc:(NSInteger)indexOfLastLetterOfDoc {
        
    // go left all spaces / go right all non-spaces (to find/store end of block)
    NSInteger indexOfLastLetterOfBlock = selectedIndex;
    if (indexOfLastLetterOfBlock > indexOfLastLetterOfDoc) {
        indexOfLastLetterOfBlock = indexOfLastLetterOfDoc;
    }
    
    // in this case there are not any letters in the docment
    if (indexOfLastLetterOfBlock < 0) return NO;
    
    BOOL anyWordsFound = YES;
    while ([self.textContent characterAtIndex:indexOfLastLetterOfBlock] == ' ') {
        if (indexOfLastLetterOfBlock > 0) {
            indexOfLastLetterOfBlock -= 1;
        } else {
            // this is only executed if we get to the left border of the document, 
            // then we go right as long as we can
            indexOfLastLetterOfBlock = selectedIndex;
            while ([self.textContent characterAtIndex:indexOfLastLetterOfBlock] == ' ') {
                if (indexOfLastLetterOfBlock < indexOfLastLetterOfDoc) {
                    indexOfLastLetterOfBlock += 1;
                } else {
                    // if there aren't any words we cannot do anything
                    anyWordsFound = NO;
                    break;
                }
            }
            break;
        }
    }
                          
    if (!anyWordsFound) return NO;
    
    while (indexOfLastLetterOfBlock < indexOfLastLetterOfDoc && 
           [self.textContent characterAtIndex:indexOfLastLetterOfBlock+1] != ' ') {
            indexOfLastLetterOfBlock += 1;
    }

    *index = indexOfLastLetterOfBlock;
    return YES;
}

- (NSInteger)findStartIndexOfSelectedBlockWithEndIndex:(NSInteger)indexOfLastLetterOfBlock {
    // go left all non-empty letters (to find begin of block)
    NSInteger indexOfFirstLetterOfBlock = indexOfLastLetterOfBlock;
    while (indexOfFirstLetterOfBlock > 0 && 
           [self.textContent characterAtIndex:indexOfFirstLetterOfBlock-1] != ' ') {
        indexOfFirstLetterOfBlock -= 1;
    }
    return indexOfFirstLetterOfBlock;
}

- (void)computeSyntaxWordWithForcedRecomputation:(BOOL)enforced {
    // highlight / print out the result
    NSRange rangeOfSelectedWord;
    NSInteger selectedTextIndex;
    if ([self getSelectedIndex:&selectedTextIndex] &&
        [self getRangeOfSelectedWord:&rangeOfSelectedWord atIndex:selectedTextIndex]) {
        
        if (!enforced && rangeOfSelectedWord.location == self.selectedSyntaxWordRange.location) return;
        
        id<JTSyntaxWord> syntaxWord = [self syntaxWordForTextInRange:rangeOfSelectedWord];
        
        self.selectedSyntaxWordRange = rangeOfSelectedWord;
        self.selectedSyntaxWord = syntaxWord;
        self.selectedSyntaxWordSuggestionIndex = -1;
        
        // set changed syntax word
        [self.keyboardAttachmentView setSelectedSyntaxWord:self.selectedSyntaxWord];
        
    } else {
        self.selectedSyntaxWord = nil;
        self.selectedSyntaxWordSuggestionIndex = -1;

        // end notification with changed syntax word
        [self.keyboardAttachmentView setSelectedSyntaxWord:nil];

    }
}

- (void)moveSelectionToIndex:(NSInteger)newIndex {
    UITextPosition *startPosition = [self.delegate beginningOfDocument];
    UITextPosition *newPosition = [self.delegate positionFromPosition:startPosition offset:newIndex];
    UITextRange *newTextRange = [self.delegate textRangeFromPosition:newPosition toPosition:newPosition];
    [self.delegate setSelectedTextRange:newTextRange];
}

- (BOOL)doesTextInRangeComplyToSyntaxWord:(NSRange)range {    
    for (NSString *className in self.syntaxWordClassNames) {
        Class<JTSyntaxWord> syntaxClass = NSClassFromString(className);
        if ([syntaxClass doesMatchWordInText:self.textContent range:range]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)getSelectedIndex:(NSInteger *)selectedIndex {
    
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) {
        return NO;
    }
    
    if (selectedRange.length > 0) {
        return NO;
    }
    
    if (selectedIndex) *selectedIndex = selectedRange.location;
    
    return YES;
}

- (BOOL)getSelectedRange:(NSRange *)selectedIndex {
    UITextRange *selectedTextRange = [self.delegate selectedTextRange];    
    UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
    
    if (!selectedTextRange) return NO;

    NSInteger startIndex = [self.delegate offsetFromPosition:docStartPosition toPosition:selectedTextRange.start];
    NSInteger endIndex = [self.delegate offsetFromPosition:docStartPosition toPosition:selectedTextRange.end];
    
    *selectedIndex = NSMakeRange(startIndex, endIndex-startIndex);
    return YES;
}

- (id<JTSyntaxWord>)syntaxWordForTextInRange:(NSRange)range {
    for (NSString *className in self.syntaxWordClassNames) {
        Class<JTSyntaxWord> syntaxClass = NSClassFromString(className);
        if ([syntaxClass doesMatchWordInText:self.textContent range:range]) {
            id<JTSyntaxWord> syntaxWord = [[syntaxClass alloc] initWithText:self.textContent inRange:range];
            return syntaxWord;
        }
    }
    return nil;
}

- (NSInteger)endIndexOfDocument {
    UITextPosition *startPositionOfDoc = [self.delegate beginningOfDocument];
    UITextPosition *endPositionOfDoc = [self.delegate endOfDocument];
    return [self.delegate offsetFromPosition:startPositionOfDoc toPosition:endPositionOfDoc];
}

- (void)selectNextSuggestionInForwardDirection:(BOOL)forward {
    
    if (![self getSelectedIndex:NULL]) return;
    
    NSInteger newIndex;
    NSString *word;
    [self nextSuggestionInForwardDirection:forward word:&word index:&newIndex];
    
    [self replaceRange:self.selectedSyntaxWordRange withText:word];

    NSRange newRange = NSMakeRange(self.selectedSyntaxWordRange.location, [word length]);
    self.selectedSyntaxWordRange = newRange;
    self.selectedSyntaxWordSuggestionIndex = newIndex;
}

- (void)nextSuggestionInForwardDirection:(BOOL)forward word:(NSString **)word index:(NSInteger *)currentIndex {
    *currentIndex = self.selectedSyntaxWordSuggestionIndex;
    NSInteger suggestionCount = [[self.selectedSyntaxWord allSuggestions] count];
    
    if (forward) {
        if (*currentIndex < suggestionCount - 1) {
            *currentIndex += 1;
        } else {
            *currentIndex = -1;
        }
    } else {
        if (*currentIndex > -1) {
            *currentIndex -= 1;
        } else {
            *currentIndex = suggestionCount - 1;
        }
    }
    
    if (*currentIndex == -1) {
        *word = [self.selectedSyntaxWord word];
    } else {
        *word = [[self.selectedSyntaxWord allSuggestions] objectAtIndex:*currentIndex];
    }

    return;
}

- (void)replaceRange:(NSRange)range withText:(NSString *)text {
    
    self.isIgnoringUpdates = YES;
    
    UITextRange *textRange = [self textRangeFromRange:range];
    [self.delegate replaceRange:textRange withText:text];
     
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isIgnoringUpdates = NO;
    });    
}

- (UITextRange *)textRangeFromRange:(NSRange)range {
    UITextPosition *startPosition = [self.delegate beginningOfDocument];
    UITextPosition *fromPosition = [self.delegate positionFromPosition:startPosition offset:range.location];
    UITextPosition *toPosition = [self.delegate positionFromPosition:startPosition offset:range.location+range.length];
    UITextRange *textRange = [self.delegate textRangeFromPosition:fromPosition toPosition:toPosition];
    return textRange;
}

- (void)selectNextSeperatorForEndOfDocument {
    NSString *word = nil;
    NSRange wordRange;
    NSInteger wordIndex;
    
    // get range of the spaces after the currently selected word
    UITextPosition *beginOfDocPosition = [self.delegate beginningOfDocument];
    UITextPosition *endOfDocPosition = [self.delegate endOfDocument];
    
    NSUInteger endIndexOfLastWord = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length;
    UITextPosition *endOfWordPosition = [self.delegate positionFromPosition:beginOfDocPosition offset:endIndexOfLastWord];

    // if the rest contain more than one whitespace replace with suggestion
    if ([self.delegate comparePosition:endOfDocPosition toPosition:endOfWordPosition] != NSOrderedSame) {
        
        if (![self.selectedSyntaxWord isKindOfClass:[JTSyntaxSeperatorWord class]]) {
            
            wordRange = NSMakeRange(self.selectedSyntaxWordRange.location+self.selectedSyntaxWordRange.length, 0);
            word = [[JTSyntaxSeperatorWord possibleSuggestions] objectAtIndex:0];
            
        } else {
            
            wordRange = self.selectedSyntaxWordRange;
            [self nextSuggestionInForwardDirection:YES word:&word index:&wordIndex];
            
        }
        
    } else {
        if ([self.selectedSyntaxWord isKindOfClass:[JTSyntaxSeperatorWord class]]) {
            
            // replace with next syntax word
            wordRange = self.selectedSyntaxWordRange;
            [self nextSuggestionInForwardDirection:YES word:&word index:&wordIndex];        
            
        } else {
            
            if (!SYNTAX_COMPLETION_WHEN_SWIPING_RIGHT) {
                wordRange = NSMakeRange(self.selectedSyntaxWordRange.location + 
                                        self.selectedSyntaxWordRange.length, 0);
            } else {
                wordRange = self.selectedSyntaxWordRange;
                [self nextSuggestionInForwardDirection:YES word:&word index:&wordIndex];
            }
        }
    }
    
    UITextRange *lastSpacesRange = [self.delegate textRangeFromPosition:endOfWordPosition toPosition:endOfDocPosition];
    NSInteger lastSpacesLength = [self.delegate offsetFromPosition:lastSpacesRange.start toPosition:lastSpacesRange.end];

    NSString *wordToReplace = [NSString stringWithFormat:@"%@ ", word ?: @""];
    NSRange wordRangeToReplace = NSMakeRange(wordRange.location, wordRange.length + lastSpacesLength);
    [self replaceRange:wordRangeToReplace withText:wordToReplace];
    
    [self computeSyntaxWordWithForcedRecomputation:YES];

}

#pragma mark - JTKeyboardAttachmentViewDelegate methods
- (void)setKeyboardAttachmentView:(JTKeyboardAttachmentView *)keyboardAttachmentView {
    if (_keyboardAttachmentView != keyboardAttachmentView) {
        _keyboardAttachmentView.delegate = nil;
        _keyboardAttachmentView = keyboardAttachmentView;
        _keyboardAttachmentView.delegate = self;
    }
}

- (void)keyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView didSelectDisplayedWordWithIndex:(NSUInteger)index {
    
}
     
@end
