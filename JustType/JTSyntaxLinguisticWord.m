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
        sharedLinguisticExpression = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z-]+$" options:0 error:NULL];
    });
    
    NSArray *matches = [sharedLinguisticExpression matchesInString:text options:0 range:range];
    return (matches.count > 0);
}

- (id)initWithWord:(NSString *)word {
    self = [super init];
    if (self) {
        self.word = word;
    }
    return self;
}

- (void)dealloc {
    self.word = nil;
}

- (NSArray *)allSuggestions {
    if (!_allSuggestions) {
    
        static UITextChecker *sharedTextChecker;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedTextChecker = [[UITextChecker alloc] init];
        });
        
        if ([self isTextCheckerAvailable]) {
            NSRange range = [self.word range];
            _allSuggestions = [sharedTextChecker 
                               guessesForWordRange:range inString:self.word 
                               language:[[NSLocale currentLocale] localeIdentifier]];
        } else {
            _allSuggestions = [NSArray array];
        }
        
    }
    
    return _allSuggestions;
}

#pragma mark - private methods
- (BOOL)isTextCheckerAvailable {
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    return [[UITextChecker availableLanguages] containsObject:localeIdentifier];
}

@end
