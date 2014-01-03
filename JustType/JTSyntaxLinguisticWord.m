//
//  JTSyntaxLinguisticWord.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTSyntaxLinguisticWord.h"
#import "NSString+JTExtension.h"

#import <UIKit/UITextChecker.h>

@interface JTSyntaxLinguisticWord ()

@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSArray *allSuggestions;

- (BOOL)isTextCheckerAvailable;
- (BOOL)wordBeginsWithUpperCaseLetter:(NSString *)word;
- (NSString *)selectedLocaleIdentifier;

@end


@implementation JTSyntaxLinguisticWord
@synthesize word = _word;
@synthesize allSuggestions = _allSuggestions;

+ (BOOL)doesMatchWord:(NSString *)word {
    return [self doesMatchWordInText:word range:[word range]];
}

+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range {
    NSRegularExpression *expression = [self sharedLinguisticExpression];
    int matchesCount = [expression numberOfMatchesInString:text options:0 range:range];
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

- (id)initWithText:(NSString *)text inRange:(NSRange)range useSuggestions:(BOOL)shouldUseSuggestions {
    self = [super init];
    if (self) {
        self.word = [text substringWithRange:range];;
        
        if (shouldUseSuggestions && [self isTextCheckerAvailable]) {

            static UITextChecker *sharedTextChecker;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                sharedTextChecker = [[UITextChecker alloc] init];
            });

            _allSuggestions = [sharedTextChecker guessesForWordRange:range inString:text language:[self selectedLocaleIdentifier]];
            
            // this checks that all suggestions are of the same case
            BOOL shouldBeUpperCase = [self wordBeginsWithUpperCaseLetter:self.word];
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *object, NSDictionary *bindings) {
                NSRegularExpression *expression = [[self class] sharedLinguisticExpression];
                int matchesCount = [expression numberOfMatchesInString:object options:0 range:NSMakeRange(0, object.length)];
                return (matchesCount > 0) && ([self wordBeginsWithUpperCaseLetter:object] == shouldBeUpperCase);
            }];
            _allSuggestions = [_allSuggestions filteredArrayUsingPredicate:predicate];

        } else {
            _allSuggestions = [NSArray array];
        }
    }
    return self;
}

- (void)dealloc {
    self.word = nil;
}

#pragma mark - private methods
- (BOOL)isTextCheckerAvailable {
    return [[UITextChecker availableLanguages] containsObject:[self selectedLocaleIdentifier]];
}

- (NSString *)selectedLocaleIdentifier {
    //NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSString *localeIdentifier = [UITextInputMode currentInputMode].primaryLanguage;
    localeIdentifier = [localeIdentifier stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    return localeIdentifier;
}

- (BOOL)wordBeginsWithUpperCaseLetter:(NSString *)word {
    NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    return [upperCaseSet characterIsMember:[word characterAtIndex:0]];
}

@end
