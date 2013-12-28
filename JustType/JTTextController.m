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

@interface JTTextController ()

@property (nonatomic, readonly) NSString *textContent;
@property (nonatomic, retain) NSArray *syntaxWordClassNames;

@property (nonatomic, assign) NSRange selectedSyntaxWordRange;
@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;

- (BOOL)getRangeOfSelectedWord:(NSRange *)range atIndex:(NSInteger)index;
- (BOOL)getRangeOfNextWord:(NSRange *)range fromIndex:(NSInteger)index;
- (BOOL)doesTextInRangeComplyToSyntaxWord:(NSRange)range;
- (id<JTSyntaxWord>)syntaxWordForTextInRange:(NSRange)range;
- (void)computeSyntaxWordWithForcedRecomputation:(BOOL)enforced;
- (BOOL)getSelectedIndex:(NSInteger *)selectedIndex;
- (void)moveSelectionToIndex:(NSInteger)newIndex;

- (BOOL)findEndIndexOfSelectedBlock:(NSInteger *)index 
                      selectedIndex:(NSInteger)selectedIndex
                      endIndexOfDoc:(NSInteger)indexOfLastLetterOfDoc;
- (NSInteger)findStartIndexOfSelectedBlockWithEndIndex:(NSInteger)indexOfLastLetterOfBlock;
- (BOOL)updateRange:(NSRange *)range withSelectedIndex:(NSInteger)selectedIndex 
  startIndexOfBlock:(NSInteger)indexOfFirstLetterOfBlock 
           endIndex:(NSInteger)indexOfLastLetterOfBlock;

@end


@implementation JTTextController
@synthesize delegate = _delegate;
@synthesize syntaxWordClassNames = _syntaxWordClassNames;
@synthesize selectedSyntaxWordRange = _selectedSyntaxWordRange;
@synthesize selectedSyntaxWord = _selectedSyntaxWord;

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
    [self computeSyntaxWordWithForcedRecomputation:NO];
}

- (void)didChangeText {
    [self computeSyntaxWordWithForcedRecomputation:YES];
}

#pragma mark - notification listeners
- (void)didSwipeLeftLong:(NSNotification *)notification {
    if (!self.selectedSyntaxWord) return;
        
    // first try to move to beginning of the selected word
    NSInteger selectedTextIndex;
    if (![self getSelectedIndex:&selectedTextIndex]) return;

    NSInteger startIndexOfSelectedWord = self.selectedSyntaxWordRange.location;
    if (selectedTextIndex > startIndexOfSelectedWord) {
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
    NSInteger selectedTextIndex;
    if (![self getSelectedIndex:&selectedTextIndex]) return;
    
    NSInteger startIndexOfSelectedWord = self.selectedSyntaxWordRange.location;
    NSInteger endIndexOfSelectedWord = self.selectedSyntaxWordRange.location + self.selectedSyntaxWordRange.length - 1;
    if (selectedTextIndex < endIndexOfSelectedWord) {
        [self moveSelectionToIndex:endIndexOfSelectedWord+1];
        return;
    }
    
    // then try to move to the beginning of the word before the selected word
    NSRange newWordRange;
    if (![self getRangeOfNextWord:&newWordRange fromIndex:endIndexOfSelectedWord + 1]) return;
    if (startIndexOfSelectedWord == newWordRange.location) return;

    NSInteger offsetFromStartPosition = newWordRange.location + newWordRange.length;
    [self moveSelectionToIndex:offsetFromStartPosition];
}

- (void)didSwipeLeftShort:(NSNotification *)notification {
    
}

- (void)didSwipeRightShort:(NSNotification *)notification {
    
}

- (void)didSwipeUp:(NSNotification *)notification {
    
}

- (void)didSwipeDown:(NSNotification *)notification {
    
}

#pragma mark - internal methods
- (NSString *)textContent {
    return [self.delegate textContent];
}

- (BOOL)getRangeOfSelectedWord:(NSRange *)range atIndex:(NSInteger)index {
    
    UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
    UITextPosition *docEndPosition = [self.delegate endOfDocument];
    
    NSInteger indexOfLastLetterOfDoc = [self.delegate offsetFromPosition:docStartPosition 
                                                              toPosition:docEndPosition] - 1;

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
    UITextPosition *startPositionOfDoc = [self.delegate beginningOfDocument];
    UITextPosition *endPositionOfDoc = [self.delegate endOfDocument];
    NSInteger endIndexOfDoc = [self.delegate offsetFromPosition:startPositionOfDoc toPosition:endPositionOfDoc];
    
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
    NSInteger beginIndexOfWord = indexOfFirstLetterOfBlock;
    
    for (NSInteger i = indexOfFirstLetterOfBlock; i <= indexOfLastLetterOfBlock; i++) {
        
        NSInteger endIndexOfWord = i+1;
        NSRange tempWordRange = NSMakeRange(beginIndexOfWord, endIndexOfWord-beginIndexOfWord);
        
        // if word from last "beginIndexOfWord" to current "i" 
        // does not match any more open up new word (with a new "beginIndexOfWord")
        if ([self doesTextInRangeComplyToSyntaxWord:tempWordRange]) {
            *range = tempWordRange;
        } else {
            // if we met the selection point already or come to the last word just break
            if (i >= selectedIndex) {
                break;
            } else {
                beginIndexOfWord = i;
                *range = NSMakeRange(beginIndexOfWord, endIndexOfWord-beginIndexOfWord);
            }
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
        
        NSLog(@"The selected text now: %@", [self.textContent substringWithRange:rangeOfSelectedWord]);
        NSLog(@"The suggestions are: %@", [self.selectedSyntaxWord allSuggestions]);
        
    } else {
        self.selectedSyntaxWord = nil;
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
    UITextRange *selectedTextRange = [self.delegate selectedTextRange];
    NSComparisonResult result = [self.delegate comparePosition:selectedTextRange.start 
                                                    toPosition:selectedTextRange.end];
    if (result != NSOrderedSame) return NO;
    
    UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
    *selectedIndex = [self.delegate offsetFromPosition:docStartPosition 
                                            toPosition:selectedTextRange.start];
    
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

@end
