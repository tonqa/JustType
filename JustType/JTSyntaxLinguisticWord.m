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

@end


@implementation JTSyntaxLinguisticWord
@synthesize word = _word;
@synthesize allSuggestions = _allSuggestions;

+ (BOOL)doesMatchWord:(NSString *)word {
    return [self doesMatchWordInText:word range:[word range]];
}

+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range {
    static NSRegularExpression *sharedLinguisticExpression;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        sharedLinguisticExpression = [NSRegularExpression regularExpressionWithPattern:@"^([\\w]+[\\w-']*)$" options:0 error:&error];
//        sharedLinguisticExpression = [NSRegularExpression regularExpressionWithPattern:@"^(([\\w]+[\\w-']*)|(\\w+\\.\\w[\\w-'.]*))$" options:0 error:&error];
        NSAssert(!error, [error description]);
    });
    
    int matchesCount = [sharedLinguisticExpression numberOfMatchesInString:text options:0 range:range];
    return (matchesCount > 0);
}

- (id)initWithText:(NSString *)text inRange:(NSRange)range {
    self = [super init];
    if (self) {
        self.word = [text substringWithRange:range];;

        static UITextChecker *sharedTextChecker;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedTextChecker = [[UITextChecker alloc] init];
        });
        
        if ([self isTextCheckerAvailable]) {
                        
            _allSuggestions = [sharedTextChecker guessesForWordRange:range inString:text language:[[NSLocale currentLocale] localeIdentifier]];
            
            // this checks that all suggestions are of the same case
            BOOL shouldBeUpperCase = [self wordBeginsWithUpperCaseLetter:self.word];
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *object, NSDictionary *bindings) {
                return ([self wordBeginsWithUpperCaseLetter:object] == shouldBeUpperCase);
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
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    return [[UITextChecker availableLanguages] containsObject:localeIdentifier];
}

- (BOOL)wordBeginsWithUpperCaseLetter:(NSString *)word {
    NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    return [upperCaseSet characterIsMember:[word characterAtIndex:0]];
}

@end
