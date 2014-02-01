//
//  JTTextController.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTTextController.h"
#import "JTKeyboardHeaders.h"

#import "JTSyntaxWord.h"
#import "JTSyntaxLinguisticWord.h"
#import "JTSyntaxSeperatorWord.h"
#import "NSString+JTUtil.h"

#define SYNTAX_COMPLETION_WHEN_SWIPING_RIGHT 0

NSString * const JTNotificationTextControllerDidRecognizeGesture = @"JTNotificationTextControllerDidRecognizeGesture";
NSString * const JTNotificationTextControllerDidProcessGesture = @"JTNotificationTextControllerDidProcessGesture";
NSString * const JTNotificationTextControllerDidExecuteAction = @"JTNotificationTextControllerDidExecuteAction";
NSString * const JTNotificationKeyDirection = @"JTNotificationKeyDirection";
NSString * const JTNotificationKeyAction = @"JTNotificationKeyAction";

@interface JTTextController ()

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


@implementation JTTextController
@synthesize delegate = _delegate;
@synthesize syntaxWordClassNames = _syntaxWordClassNames;
@synthesize selectedSyntaxWordRange = _selectedSyntaxWordRange;
@synthesize selectedSyntaxWord = _selectedSyntaxWord;
@synthesize selectedSyntaxWordSuggestionIndex = _selectedSyntaxWordSuggestionIndex;
@synthesize isIgnoringSelectionUpdates = _isIgnoringSelectionUpdates;
@synthesize isIgnoringChangeUpdates = _isIgnoringChangeUpdates;
@synthesize keyboardAttachmentView = _keyboardAttachmentView;
@synthesize useSyntaxCompletion = _useSyntaxCompletion;
@synthesize textSuggestionDelegate = _textSuggestionDelegate;

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
        
        self.useSyntaxCompletion = YES;
        
        NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
        [notifCenter addObserver:self selector:@selector(didSwipe:) name:JTNotificationTextControllerDidRecognizeGesture object:nil];
        [notifCenter addObserver:self selector:@selector(didChangeKeyboardTextInputMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - textview / textfield notifier methods
- (void)didChangeSelection {
    if (!self.isIgnoringSelectionUpdates && !self.isIgnoringChangeUpdates && self.delegate.isFirstResponder) {
        self.isIgnoringSelectionUpdates = YES;
        [self computeSyntaxWordWithForcedRecomputation:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isIgnoringSelectionUpdates = NO;
        });
    }
}

- (void)didChangeText {
    if (!self.isIgnoringChangeUpdates && self.delegate.isFirstResponder) {
        self.isIgnoringChangeUpdates = YES;
        [self computeSyntaxWordWithForcedRecomputation:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isIgnoringChangeUpdates = NO;
        });
    }
}

#pragma mark - public methods
- (void)moveToPreviousWord {
    if (![self.delegate isFirstResponder]) return;
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

- (void)moveToNextWord {
    if (![self.delegate isFirstResponder]) return;
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
        self.isIgnoringChangeUpdates = YES;
        [self selectNextSeperatorForEndOfDocument];
        [self moveSelectionToIndex:[self endIndexOfDocument]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isIgnoringChangeUpdates = NO;
        });
        return;
    }
    
    NSInteger offsetFromStartPosition = newWordRange.location + newWordRange.length;
    [self moveSelectionToIndex:offsetFromStartPosition];
}

- (void)moveToPreviousLetter {
    if (![self.delegate isFirstResponder]) return;
    
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) return;
    
    NSInteger currentIndex = selectedRange.location;
    if (currentIndex <= 0) return;
    
    [self moveSelectionToIndex:currentIndex-1];
}

- (void)moveToNextLetter {
    if (![self.delegate isFirstResponder]) return;
    
    NSRange selectedRange;
    if (![self getSelectedRange:&selectedRange]) return;
    
    NSInteger currentIndex = selectedRange.location+selectedRange.length;
    NSInteger maximumIndex = [self endIndexOfDocument];
    if (currentIndex >= maximumIndex) {
        self.isIgnoringChangeUpdates = YES;
        [self selectNextSeperatorForEndOfDocument];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isIgnoringChangeUpdates = NO;
        });
        return;
    }
    
    [self moveSelectionToIndex:currentIndex+1];
}

- (void)selectPreviousSuggestion {
    if (![self.delegate isFirstResponder]) return;
    
    [self selectNextSuggestionInForwardDirection:NO];
}

- (void)selectNextSuggestion {
    if (![self.delegate isFirstResponder]) return;
    
    [self selectNextSuggestionInForwardDirection:YES];
}

- (void)selectSuggestionByIndex:(NSInteger)index {
    if (![self.delegate isFirstResponder]) return;
    if (!self.selectedSyntaxWord) return;
    
    NSString *word = [self selectedTextWithSyntaxWordSuggestionIndex:index];

    self.isIgnoringChangeUpdates = YES;
    
    [self replaceRange:self.selectedSyntaxWordRange withText:word];
    
    NSRange newRange = NSMakeRange(self.selectedSyntaxWordRange.location, [word length]);
    self.selectedSyntaxWordRange = newRange;
    self.selectedSyntaxWordSuggestionIndex = index;
    
    if ([self.textSuggestionDelegate respondsToSelector:@selector(didSelectSuggestionIndex:)]) {
        [self.textSuggestionDelegate didSelectSuggestionIndex:index];
    }
    
    [self.keyboardAttachmentView setHighlightedIndex:index];
    
    [self replaceHighlightingWithRange:self.selectedSyntaxWordRange];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isIgnoringChangeUpdates = NO;
    });
}

#pragma mark - notification listeners
- (void)didSwipe:(NSNotification *)notification {
    NSString *direction = [notification.userInfo objectForKey:JTNotificationKeyDirection];
    
    SEL action;
    if ([direction isEqualToString:JTKeyboardGestureSwipeLeftLong]) {
        action = @selector(didSwipeLeftLong:);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeLeftShort]) {
        action = @selector(didSwipeLeftShort:);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeRightLong]) {
        action = @selector(didSwipeRightLong:);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeRightShort]) {
        action = @selector(didSwipeRightShort:);
    } else if ([direction isEqualToString:JTKeyboardGestureSwipeUp]) {
        action = @selector(didSwipeUp:);
    } else {
        action = @selector(didSwipeDown:);
    }
    
    // we do this here because performSelector: throws a warning that this would not be typesafe.
    ((void (*)(id, SEL, NSNotification *))[self methodForSelector:action])(self, action, notification);
}

- (void)didSwipeLeftLong:(NSNotification *)notification {
    [self moveToPreviousWord];
    [self postDidProcessNotificationForDirection:JTKeyboardGestureSwipeLeftLong];
}

- (void)didSwipeRightLong:(NSNotification *)notification {
    [self moveToNextWord];
    [self postDidProcessNotificationForDirection:JTKeyboardGestureSwipeRightLong];
}

- (void)didSwipeLeftShort:(NSNotification *)notification {
    [self moveToPreviousLetter];
    [self postDidProcessNotificationForDirection:JTKeyboardGestureSwipeLeftShort];
}

- (void)didSwipeRightShort:(NSNotification *)notification {
    [self moveToNextLetter];
    [self postDidProcessNotificationForDirection:JTKeyboardGestureSwipeRightShort];
}

- (void)didSwipeUp:(NSNotification *)notification {
    [self selectPreviousSuggestion];
    [self postDidProcessNotificationForDirection:JTKeyboardGestureSwipeUp];
}

- (void)didSwipeDown:(NSNotification *)notification {
    [self selectNextSuggestion];
    [self postDidProcessNotificationForDirection:JTKeyboardGestureSwipeDown];
}

- (void)didChangeKeyboardTextInputMode:(NSNotification *)notification {
    [self computeSyntaxWordWithForcedRecomputation:YES];
}

#pragma mark - internal methods
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
    while ([self isEmptyCharacter:[self.delegate.textContent characterAtIndex:newStartIndex]]) {
        newStartIndex += 1;
        if (newStartIndex + 1 >= endIndexOfDoc) {
            return NO;
        }
    }
    
    return [self getRangeOfSelectedWord:range atIndex:newStartIndex + 1];
}


- (BOOL)updateRange:(NSRange *)range withSelectedIndex:(NSInteger)selectedIndex 
  startIndexOfBlock:(NSInteger)indexOfFirstLetterOfBlock 
           endIndex:(NSInteger)indexOfLastLetterOfBlock {
    
    // go right and find the last largest matching word step-by-step
    // (until you find a word containing the current index, otherwise the last word)
    BOOL selectionIndexFound = NO; 
    NSInteger beginIndexOfWord = indexOfFirstLetterOfBlock;
    
    for (NSInteger i = indexOfFirstLetterOfBlock; i <= indexOfLastLetterOfBlock; i++) {
        
        NSInteger endIndexOfWord = i+1;
        NSRange tempWordRange = NSMakeRange(beginIndexOfWord, endIndexOfWord-beginIndexOfWord);
        
        if (i >= selectedIndex) {
            selectionIndexFound = YES;
        }

        // if word from last "beginIndexOfWord" to current "i"
        // does not match any more open up new word (with a new "beginIndexOfWord")
        if (tempWordRange.length == 1 || [self doesTextInRangeComplyToSyntaxWord:tempWordRange]) {
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
    while ([self isEmptyCharacter:[self.delegate.textContent characterAtIndex:indexOfLastLetterOfBlock]]) {
        if (indexOfLastLetterOfBlock > 0) {
            indexOfLastLetterOfBlock -= 1;
        } else {
            // this is only executed if we get to the left border of the document, 
            // then we go right as long as we can
            indexOfLastLetterOfBlock = selectedIndex;
            do {
                if (indexOfLastLetterOfBlock < indexOfLastLetterOfDoc) {
                    indexOfLastLetterOfBlock += 1;
                } else {
                    // if there aren't any words we cannot do anything
                    anyWordsFound = NO;
                    break;
                }
            } while ([self isEmptyCharacter:[self.delegate.textContent characterAtIndex:indexOfLastLetterOfBlock]]);

            break;
        }
    }
                          
    if (!anyWordsFound) return NO;
    
    while (indexOfLastLetterOfBlock < indexOfLastLetterOfDoc && 
           ![self isEmptyCharacter:[self.delegate.textContent characterAtIndex:indexOfLastLetterOfBlock+1]]) {
            indexOfLastLetterOfBlock += 1;
    }

    *index = indexOfLastLetterOfBlock;
    return YES;
}

- (NSInteger)findStartIndexOfSelectedBlockWithEndIndex:(NSInteger)indexOfLastLetterOfBlock {
    // go left all non-empty letters (to find begin of block)
    NSInteger indexOfFirstLetterOfBlock = indexOfLastLetterOfBlock;
    while (indexOfFirstLetterOfBlock > 0 && 
           ![self isEmptyCharacter:[self.delegate.textContent characterAtIndex:indexOfFirstLetterOfBlock-1]]) {
        indexOfFirstLetterOfBlock -= 1;
    }
    return indexOfFirstLetterOfBlock;
}

- (void)computeSyntaxWordWithForcedRecomputation:(BOOL)enforced {
    // highlight / print out the result
    NSRange rangeOfSelectedWord;
    NSInteger selectedTextIndex;
    // NSLog(@"willChangeWithEnforced: %@", @(enforced));
    if ([self getSelectedIndex:&selectedTextIndex] &&
        [self getRangeOfSelectedWord:&rangeOfSelectedWord atIndex:selectedTextIndex]) {
        
        //NSLog(@"didChange: '%@'", self.delegate.textContent);

        if (!enforced && self.selectedSyntaxWord && rangeOfSelectedWord.location == self.selectedSyntaxWordRange.location) {
            return;
        }
        
        id<JTSyntaxWord> syntaxWord = [self syntaxWordForTextInRange:rangeOfSelectedWord];
        
        self.selectedSyntaxWordRange = rangeOfSelectedWord;
        self.selectedSyntaxWord = syntaxWord;
        self.selectedSyntaxWordSuggestionIndex = -1;
        
        // this allows others to display suggestions
        if ([self.textSuggestionDelegate respondsToSelector:@selector(didSelectWord:atRange:suggestions:)]) {
            [self.textSuggestionDelegate didSelectWord:[syntaxWord text] atRange:rangeOfSelectedWord suggestions:[syntaxWord allSuggestions]];
        }
        
        // set changed syntax word
        [self.keyboardAttachmentView setSelectedSyntaxWord:self.selectedSyntaxWord];
        [self.keyboardAttachmentView setHighlightedIndex:-1];
        
        [self replaceHighlightingWithRange:self.selectedSyntaxWordRange];
        
    } else {
        self.selectedSyntaxWord = nil;
        self.selectedSyntaxWordSuggestionIndex = -1;
        
        if ([self.textSuggestionDelegate respondsToSelector:@selector(didClearSelection)]) {
            [self.textSuggestionDelegate didClearSelection];
        }

        // end notification with changed syntax word
        [self.keyboardAttachmentView setSelectedSyntaxWord:nil];
        
        [self replaceHighlightingWithRange:NSMakeRange(0, 0)];
    }
}

- (void)replaceHighlightingWithRange:(NSRange)range {
    
    UITextRange *selectedTextRange = self.delegate.selectedTextRange;
    NSInteger offset = [self.delegate offsetFromPosition:self.delegate.beginningOfDocument toPosition:selectedTextRange.start];
    NSInteger selectedRangeLength = [self.delegate offsetFromPosition:selectedTextRange.start toPosition:selectedTextRange.end];

    [self.delegate replaceHighlightingWithRange:range];
    
    UITextPosition *selectedTextPosition = [self.delegate positionFromPosition:self.delegate.beginningOfDocument offset:offset];
    UITextPosition *selectedTextEnd = [self.delegate positionFromPosition:self.delegate.beginningOfDocument offset:offset + selectedRangeLength];
    selectedTextRange = [self.delegate textRangeFromPosition:selectedTextPosition toPosition:selectedTextEnd];
    self.delegate.selectedTextRange = selectedTextRange;

}

- (BOOL)doesTextInRangeComplyToSyntaxWord:(NSRange)range {    
    for (NSString *className in self.syntaxWordClassNames) {
        Class<JTSyntaxWord> syntaxClass = NSClassFromString(className);
        if ([syntaxClass doesMatchWordInText:self.delegate.textContent range:range]) {
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

- (NSString *)selectedTextWithSyntaxWordSuggestionIndex:(NSInteger)index {
    NSString *selectedText;
    if (index == -1) {
        selectedText = [self.selectedSyntaxWord text];
    } else {
        selectedText = [[self.selectedSyntaxWord allSuggestions] objectAtIndex:index];
    }
    return selectedText;
}

- (id<JTSyntaxWord>)syntaxWordForTextInRange:(NSRange)range {
    for (NSString *className in self.syntaxWordClassNames) {
        Class<JTSyntaxWord> syntaxClass = NSClassFromString(className);
        if ([syntaxClass doesMatchWordInText:self.delegate.textContent range:range]) {
            
            // If we are at end of text and at end of last block
            // then use 'partial word' suggestions. Else use suggestions
            // with same number of letters.
            BOOL isAtEndOfWordAndText = [self rangeIsAtEndOfWordAndText:range];
            
            // we need a check for the textInputMode (iOS7 only)
            id<JTSyntaxWord> syntaxWord = [[syntaxClass alloc] initWithText:self.delegate.textContent inRange:range useSuggestions:self.useSyntaxCompletion isCurrentlyWritingWord:isAtEndOfWordAndText textInputMode:[self selectedTextInputMode]];
            
            return syntaxWord;
        }
    }
    return nil;
}

- (BOOL)rangeIsAtEndOfWordAndText:(NSRange)range {
    // first get the selected index
    NSInteger selectedIndex;
    BOOL selectedIndexWasFound = [self getSelectedIndex:&selectedIndex];
    if (!selectedIndexWasFound) {
        return NO;
    }
    
    // then compare the word range with the end index of the selected word
    NSUInteger endPositionOfWord = range.location + range.length;
    if (endPositionOfWord != selectedIndex) {
        return NO;
    }
    
    // then compare the word range with the end index of the document
    UITextRange *selectedTextRange = [self.delegate selectedTextRange];
    UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
    NSInteger textEndIndex = [self.delegate offsetFromPosition:docStartPosition toPosition:selectedTextRange.end];
    if (endPositionOfWord != textEndIndex) {
        return NO;
    }
    
    // if every check succeeded then we have found
    // the right range at the end of the document
    return YES;
}

- (void)selectNextSuggestionInForwardDirection:(BOOL)forward {
    
    if (![self getSelectedIndex:NULL]) return;
    
    NSInteger newIndex;
    NSString *word;
    [self nextSuggestionInForwardDirection:forward word:&word index:&newIndex];
    [self selectSuggestionByIndex:newIndex];
}

- (void)nextSuggestionInForwardDirection:(BOOL)forward
                                    word:(NSString **)word
                                   index:(NSInteger *)currentIndex {
    
    NSInteger suggestionCount = [[self.selectedSyntaxWord allSuggestions] count];
    *currentIndex = self.selectedSyntaxWordSuggestionIndex;
    
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

    *word = [self selectedTextWithSyntaxWordSuggestionIndex:*currentIndex];

    return;
}

- (void)replaceRange:(NSRange)range withText:(NSString *)text {
    
    UITextRange *selectedTextRange = self.delegate.selectedTextRange;
    NSInteger offset = [self.delegate offsetFromPosition:self.delegate.beginningOfDocument toPosition:selectedTextRange.start];
    
    UITextRange *textRange = [self textRangeFromRange:range];
    [self.delegate replaceRange:textRange withText:text];
    
    if (offset > range.location + range.length) {
        NSInteger lengthDiff = text.length - range.length;
        UITextPosition *selectedTextPosition = [self.delegate positionFromPosition:self.delegate.beginningOfDocument offset:offset+lengthDiff];
        selectedTextRange = [self.delegate textRangeFromPosition:selectedTextPosition toPosition:selectedTextPosition];
        self.delegate.selectedTextRange = selectedTextRange;
    }
}

- (void)selectNextSeperatorForEndOfDocument {
    NSString *word = nil;
    
    // get range of the spaces after the currently selected word
    UITextPosition *beginOfDocPosition = [self.delegate beginningOfDocument];
    UITextPosition *endOfDocPosition = [self.delegate endOfDocument];
    
    NSUInteger endIndexOfLastWord = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length;
    UITextPosition *endOfWordPosition = [self.delegate positionFromPosition:beginOfDocPosition offset:endIndexOfLastWord];

    BOOL hadWhiteSpaces = [self.delegate comparePosition:endOfDocPosition toPosition:endOfWordPosition] != NSOrderedSame;

    [self trimDownLastWhitespacesToOneWhitespace];

    if (!hadWhiteSpaces) {
        [self computeSyntaxWordWithForcedRecomputation:YES];
        return;
    }
    
    // if the rest contain more than one whitespace replace with suggestion
    if ([self.selectedSyntaxWord isKindOfClass:[JTSyntaxSeperatorWord class]]) {
        
        //[self selectNextSuggestionInForwardDirection:YES];

    } else {
        
        if (SYNTAX_COMPLETION_WHEN_SWIPING_RIGHT) {
            [self selectNextSuggestionInForwardDirection:YES];
        }
        
        word = [[JTSyntaxSeperatorWord possibleSuggestions] objectAtIndex:0];
        CGFloat wordIndex = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length;
        NSRange wordRangeToReplace = NSMakeRange(wordIndex, 0);
        
        [self replaceRange:wordRangeToReplace withText:word];
        [self computeSyntaxWordWithForcedRecomputation:YES];
    }
}

- (UITextInputMode *)selectedTextInputMode {
    UITextInputMode *textInputMode = nil;
    if ([self.delegate respondsToSelector:@selector(textInputMode)]) {
        textInputMode = [self.delegate textInputMode];
    }
    return textInputMode;
}

#pragma mark - JTKeyboardAttachmentViewDelegate methods
- (void)setKeyboardAttachmentView:(JTKeyboardAttachmentView *)keyboardAttachmentView {
    if (_keyboardAttachmentView != keyboardAttachmentView) {
        _keyboardAttachmentView.delegate = nil;
        _keyboardAttachmentView = keyboardAttachmentView;
        _keyboardAttachmentView.delegate = self;
    }
}

- (void)keyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView didSelectIndex:(NSInteger)index {
    [self selectSuggestionByIndex:index];
}

- (void)switchcaseForKeyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView {
    if (![self getSelectedIndex:NULL]) return;
    
    NSRange wordRangeToReplace = self.selectedSyntaxWordRange;
    NSInteger index = self.selectedSyntaxWordSuggestionIndex;
    NSString *word = [self selectedTextWithSyntaxWordSuggestionIndex:index];
    BOOL isUppercase = [word beginsWithUpperCaseLetter];
    
    if (isUppercase) {
        word = [word lowercaseString];
        [self postDidProcessNotificationForAction:JTKeyboardActionLowercased];
    } else {
        word = [word capitalizedString];
        [self postDidProcessNotificationForAction:JTKeyboardActionCapitalized];
    }
    
    [self replaceRange:wordRangeToReplace withText:word];
    [self computeSyntaxWordWithForcedRecomputation:YES];
}

#pragma mark - helper methods
- (void)trimDownLastWhitespacesToOneWhitespace {
    // get range of the spaces after the currently selected word
    UITextPosition *beginOfDocPosition = [self.delegate beginningOfDocument];
    UITextPosition *endOfDocPosition = [self.delegate endOfDocument];
    
    NSUInteger endIndexOfLastWord = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length;
    UITextPosition *endOfWordPosition = [self.delegate positionFromPosition:beginOfDocPosition offset:endIndexOfLastWord];
    
    // replace with one whitespace
    UITextRange *lastSpacesRange = [self.delegate textRangeFromPosition:endOfWordPosition toPosition:endOfDocPosition];
    NSInteger lastSpacesLength = [self.delegate offsetFromPosition:lastSpacesRange.start toPosition:lastSpacesRange.end];
    CGFloat wordIndex = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length;
    
    NSRange wordRangeToReplace = NSMakeRange(wordIndex, lastSpacesLength);
    [self replaceRange:wordRangeToReplace withText:@" "];
    
}

- (BOOL)isEmptyCharacter:(unichar)character {
    switch (character) {
        case ' ':
        case '\n':
        case '\t':
        case '\r':
        case '\f':
        case '\a':
            return YES; break;
    }
    return NO;
}

- (void)postDidProcessNotificationForDirection:(NSString *)direction {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:direction forKey:JTNotificationKeyDirection];
    [[NSNotificationCenter defaultCenter] postNotificationName:JTNotificationTextControllerDidProcessGesture object:self userInfo:userInfo];
}

- (void)postDidProcessNotificationForAction:(NSString *)action {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:action forKey:JTNotificationKeyAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:JTNotificationTextControllerDidExecuteAction object:self userInfo:userInfo];
}

- (UITextRange *)textRangeFromRange:(NSRange)range {
    UITextPosition *startPosition = [self.delegate beginningOfDocument];
    UITextPosition *fromPosition = [self.delegate positionFromPosition:startPosition offset:range.location];
    UITextPosition *toPosition = [self.delegate positionFromPosition:startPosition offset:range.location+range.length];
    UITextRange *textRange = [self.delegate textRangeFromPosition:fromPosition toPosition:toPosition];
    return textRange;
}

- (NSInteger)endIndexOfDocument {
    UITextPosition *startPositionOfDoc = [self.delegate beginningOfDocument];
    UITextPosition *endPositionOfDoc = [self.delegate endOfDocument];
    return [self.delegate offsetFromPosition:startPositionOfDoc toPosition:endPositionOfDoc];
}

- (void)moveSelectionToIndex:(NSInteger)newIndex {
    UITextPosition *startPosition = [self.delegate beginningOfDocument];
    UITextPosition *newPosition = [self.delegate positionFromPosition:startPosition offset:newIndex];
    UITextRange *newTextRange = [self.delegate textRangeFromPosition:newPosition toPosition:newPosition];
    [self.delegate setSelectedTextRange:newTextRange];
}

- (void)triggerUpdateHighlighting {
    [self replaceHighlightingWithRange:self.selectedSyntaxWordRange];
}

@end
