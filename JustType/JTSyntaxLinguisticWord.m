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

- (id)initWithText:(NSString *)text inRange:(NSRange)range useSuggestions:(BOOL)shouldUseSuggestions usePartialSuggestionsFirst:(BOOL)usePartialSuggestionsFirst textInputMode:(UITextInputMode *)textInputMode {

    self = [super init];
    if (self) {
        _text = [text substringWithRange:range];
        _textInputMode = textInputMode;
        
        if (shouldUseSuggestions && [self isTextCheckerAvailable]) {

            NSMutableArray *allSuggestions = [NSMutableArray array];
            NSString *locale = [self selectedLocaleIdentifier];
            if (usePartialSuggestionsFirst) {
                [allSuggestions addObjectsFromArray:[self.class.sharedTextChecker completionsForPartialWordRange:range inString:text language:locale]];
                [allSuggestions addObjectsFromArray:[self.class.sharedTextChecker guessesForWordRange:range inString:text language:locale]];
            } else {
                [allSuggestions addObjectsFromArray:[self.class.sharedTextChecker guessesForWordRange:range inString:text language:locale]];
                [allSuggestions addObjectsFromArray:[self.class.sharedTextChecker completionsForPartialWordRange:range inString:text language:locale]];
            }
            
            // this checks that all suggestions are of the same case
            BOOL shouldBeUpperCase = [self.text beginsWithUpperCaseLetter];
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *object, NSDictionary *bindings) {
                NSRegularExpression *expression = [[self class] sharedLinguisticExpression];
                NSUInteger matchesCount = [expression numberOfMatchesInString:object options:0 range:NSMakeRange(0, object.length)];
                return (matchesCount > 0) && ([object beginsWithUpperCaseLetter] == shouldBeUpperCase);
            }];
            [allSuggestions filterUsingPredicate:predicate];
            _allSuggestions = allSuggestions;

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

@end
