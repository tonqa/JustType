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

@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;

- (BOOL)isTextInRangeSyntaxWord:(NSRange)range;
- (id<JTSyntaxWord>)syntaxWordForTextInRange:(NSRange)range;
- (BOOL)getRangeOfCurrentlySelectedWord:(NSRange *)range;
- (void)computeSyntaxWordWithForcedRecomputation:(BOOL)enforced;

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
@synthesize selectedRange = _selectedRange;
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
    
    UITextRange *selectedTextRange = [self.delegate selectedTextRange];
    NSComparisonResult result = [self.delegate comparePosition:selectedTextRange.start 
                                                    toPosition:selectedTextRange.end];
    if (result == NSOrderedSame) {
        UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
        NSInteger selectedIndex = [self.delegate offsetFromPosition:docStartPosition 
                                                         toPosition:selectedTextRange.start];

        while ([self.textContent characterAtIndex:selectedIndex-1] == ' ') {
            selectedIndex -= 1;
        }
        
        while ([self.textContent characterAtIndex:selectedIndex-1] != ' ') {
            selectedIndex -= 1;
        }
        
        UITextPosition *newPosition = [self.delegate positionFromPosition:docStartPosition offset:selectedIndex];
        UITextRange *newTextRange = [self.delegate textRangeFromPosition:newPosition toPosition:newPosition];
        [self.delegate setSelectedTextRange:newTextRange];
    }
}

- (void)didSwipeRightLong:(NSNotification *)notification {

    UITextRange *selectedTextRange = [self.delegate selectedTextRange];
    NSComparisonResult result = [self.delegate comparePosition:selectedTextRange.start 
                                                    toPosition:selectedTextRange.end];
    if (result == NSOrderedSame) {
        UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
        NSInteger selectedIndex = [self.delegate offsetFromPosition:docStartPosition 
                                                         toPosition:selectedTextRange.start];
        
        while ([self.textContent characterAtIndex:selectedIndex] == ' ') {
            selectedIndex += 1;
        }
        
        while ([self.textContent characterAtIndex:selectedIndex] != ' ') {
            selectedIndex += 1;
        }
        
        UITextPosition *newPosition = [self.delegate positionFromPosition:docStartPosition offset:selectedIndex];
        UITextRange *newTextRange = [self.delegate textRangeFromPosition:newPosition toPosition:newPosition];
        [self.delegate setSelectedTextRange:newTextRange];
    }
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

- (BOOL)getRangeOfCurrentlySelectedWord:(NSRange *)range {
    UITextRange *selectedTextRange = [self.delegate selectedTextRange];
    NSComparisonResult result = [self.delegate comparePosition:selectedTextRange.start 
                                                    toPosition:selectedTextRange.end];
    if (result != NSOrderedSame) return NO;
    
    UITextPosition *docStartPosition = [self.delegate beginningOfDocument];
    UITextPosition *docEndPosition = [self.delegate endOfDocument];
    
    NSInteger indexOfLastLetterOfDoc = [self.delegate offsetFromPosition:docStartPosition 
                                                              toPosition:docEndPosition] - 1;
    NSInteger selectedIndex = [self.delegate offsetFromPosition:docStartPosition 
                                                     toPosition:selectedTextRange.start];

    NSInteger indexOfLastLetterOfBlock;
    if (![self findEndIndexOfSelectedBlock:&indexOfLastLetterOfBlock 
                             selectedIndex:selectedIndex 
                             endIndexOfDoc:indexOfLastLetterOfDoc]) {
        return NO;
    }
        
    NSInteger indexOfFirstLetterOfBlock = [self findStartIndexOfSelectedBlockWithEndIndex:indexOfLastLetterOfBlock];
    
    return [self updateRange:range withSelectedIndex:selectedIndex 
           startIndexOfBlock:indexOfFirstLetterOfBlock 
                    endIndex:indexOfLastLetterOfBlock];
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
        if ([self isTextInRangeSyntaxWord:tempWordRange]) {
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
    if ([self getRangeOfCurrentlySelectedWord:&rangeOfSelectedWord]) {
        
        if (!enforced && rangeOfSelectedWord.location == self.selectedRange.location) return;
        
        id<JTSyntaxWord> syntaxWord = [self syntaxWordForTextInRange:rangeOfSelectedWord];
        
        self.selectedRange = rangeOfSelectedWord;
        self.selectedSyntaxWord = syntaxWord;
        
        NSLog(@"The selected text now: %@", [self.textContent substringWithRange:rangeOfSelectedWord]);
        NSLog(@"The suggestions are: %@", [self.selectedSyntaxWord allSuggestions]);
        
    } else {
        self.selectedSyntaxWord = nil;
    }
}

- (BOOL)isTextInRangeSyntaxWord:(NSRange)range {    
    for (NSString *className in self.syntaxWordClassNames) {
        Class<JTSyntaxWord> syntaxClass = NSClassFromString(className);
        if ([syntaxClass doesMatchWordInText:self.textContent range:range]) {
            return YES;
        }
    }
    return NO;
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
