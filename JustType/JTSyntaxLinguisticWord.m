//
//  JTSyntaxLinguisticWord.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTSyntaxLinguisticWord.h"
#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>
#import "NSString+JTUtil.h"

@interface JTSyntaxLinguisticWord ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSArray *allSuggestions;
@property (nonatomic, retain) UITextInputMode *textInputMode;
@property (nonatomic, retain) NSCache *scoreCache;

- (BOOL)isTextCheckerAvailable;
- (NSString *)selectedLocaleIdentifier;

@end


@implementation JTSyntaxLinguisticWord
@synthesize text = _text;
@synthesize allSuggestions = _allSuggestions;
@synthesize textInputMode = _textInputMode;

+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range {
    NSRegularExpression *expression = [self sharedLinguisticExpression];
    NSUInteger matchesCount = [expression numberOfMatchesInString:text options:0 range:range];
    return (matchesCount > 0);
}

+ (NSRegularExpression *)sharedLinguisticExpression {
    static NSRegularExpression *sharedLinguisticExpression;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        sharedLinguisticExpression = [NSRegularExpression regularExpressionWithPattern:@"^([\\w]+[\\w-']*)$" options:0 error:&error];
        //        sharedLinguisticExpression = [NSRegularExpression regularExpressionWithPattern:@"^(([\\w]+[\\w-']*)|(\\w+\\.\\w[\\w-'.]*))$" options:0 error:&error];
        NSAssert(!error, [error description]);
    });
    
    return sharedLinguisticExpression;
}

+ (UITextChecker *)sharedTextChecker {
    static UITextChecker *sharedTextChecker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTextChecker = [[UITextChecker alloc] init];
    });
    return sharedTextChecker;
}

- (id)initWithText:(NSString *)text inRange:(NSRange)range useSuggestions:(BOOL)shouldUseSuggestions isCurrentlyWritingWord:(BOOL)isCurrentlyWritingWord textInputMode:(UITextInputMode *)textInputMode {

    self = [super init];
    if (self) {
        _text = [text substringWithRange:range];
        _textInputMode = textInputMode;
        _scoreCache = [[NSCache alloc] init];
        
        if (shouldUseSuggestions && [self isTextCheckerAvailable]) {

            NSMutableOrderedSet *allSuggestions = [NSMutableOrderedSet orderedSet];
            NSString *locale = [self selectedLocaleIdentifier];
            [allSuggestions addObjectsFromArray:[self.class.sharedTextChecker guessesForWordRange:range inString:text language:locale]];
            [allSuggestions addObjectsFromArray:[self.class.sharedTextChecker completionsForPartialWordRange:range inString:text language:locale]];
            [allSuggestions filterUsingPredicate:[self wordPredicateWhileWritingWord:isCurrentlyWritingWord]];
            _allSuggestions = [allSuggestions sortedArrayUsingComparator:[self wordComparatorWhileWritingWord:isCurrentlyWritingWord]];

        } else {
            _allSuggestions = [NSArray array];
        }
    }
    return self;
}

- (void)dealloc {
    self.text = nil;
}

#pragma mark - private methods
- (BOOL)isTextCheckerAvailable {
    return [[UITextChecker availableLanguages] containsObject:[self selectedLocaleIdentifier]];
}

- (NSString *)selectedLocaleIdentifier {
    //NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSString *localeIdentifier = self.textInputMode.primaryLanguage;
    localeIdentifier = [localeIdentifier stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    return localeIdentifier;
}

- (UITextInputMode *)textInputMode {
    if (!_textInputMode) {
        // The global method 'currentInputMode' is deprecated, so we check for compatibility reasons up to iOS 6. From iOS 7 on the inputMode is a property of the text input element and will be given by textcontroller.
        Class textInputModeClass = [UITextInputMode class];
        if ([textInputModeClass respondsToSelector:@selector(currentInputMode)]) {
            return [textInputModeClass performSelector:@selector(currentInputMode)];
        }
    }
    return _textInputMode;
}

- (BOOL)canBeCapitalized {
    return YES;
}

- (NSPredicate *)wordPredicateWhileWritingWord:(BOOL)isCurrentlyWriting {
    NSString *text = self.text;
    BOOL shouldBeUpperCase = [self.text beginsWithUpperCaseLetter];
    
    // while writing we only allow longer words, later we also allow words with one letter less
    NSUInteger textLength = (isCurrentlyWriting) ? self.text.length : self.text.length - 1;
    
    return [NSPredicate predicateWithBlock:^BOOL(NSString *object, NSDictionary *bindings) {
        if (object.length < textLength) return NO;
        if ([object isEqualToString:text]) return NO;
        
        NSRegularExpression *expression = [[self class] sharedLinguisticExpression];
        NSUInteger matchesCount = [expression numberOfMatchesInString:object options:0 range:NSMakeRange(0, object.length)];
        
        return (matchesCount > 0) && ([object beginsWithUpperCaseLetter] == shouldBeUpperCase);
    }];
}

- (NSComparisonResult (^)(NSString *obj1, NSString *obj2))wordComparatorWhileWritingWord:(BOOL)isWritingWord {
        
    NSString *text = self.text;
    NSInteger bestTextLength = isWritingWord ? self.text.length + 1 : self.text.length;
    return ^NSComparisonResult(NSString *obj1, NSString *obj2) {

        // calculate similarity score
        CGFloat score1 = [self cachedScoreForWord:obj1 inText:text bestTextLength:bestTextLength];
        CGFloat score2 = [self cachedScoreForWord:obj2 inText:text bestTextLength:bestTextLength];

        //NSLog(@"compare: %@ (%f) - %@ (%f)", obj1, score1, obj2, score2);

        // order by this score
        if (score1 > score2)
            return NSOrderedAscending;
        else if (score1 < score2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    };
}

- (CGFloat)cachedScoreForWord:(NSString *)word inText:(NSString *)text
               bestTextLength:(NSInteger)bestTextLength {
    
    CGFloat score1;
    NSNumber *score1Val = [self.scoreCache objectForKey:word];
    
    if (score1Val) {
        score1 = [score1Val floatValue];
    } else {
        NSInteger matchedLetters1 = [self distanceBetweenText:text inWord:word];
        NSInteger lengthDistance1 = ABS((NSInteger)word.length - bestTextLength);
        score1 = 1.0 * matchedLetters1 / text.length +
        (1.0 - ABS(1.0 * lengthDistance1 / word.length));
        [self.scoreCache setObject:@(score1) forKey:word];
    }
    
    return score1;
}

- (NSUInteger)distanceBetweenText:(NSString *)text inWord:(NSString *)word {
    NSUInteger distance = 0;
    NSUInteger maxDistance = MIN(text.length, word.length);
    for (NSInteger charIdx = 0; charIdx < maxDistance; charIdx++) {
        if ([text characterAtIndex:charIdx] == [word characterAtIndex:charIdx]) {
            distance++;
        }
    }
    return distance;
}

@end
