//
//  JTSyntaxSeperatorWord.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTSyntaxSeperatorWord.h"
#import "NSString+JTExtension.h"

@interface JTSyntaxSeperatorWord ()

@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSArray *allSuggestions;

@end


@implementation JTSyntaxSeperatorWord
@synthesize word = _word;
@synthesize allSuggestions = _allSuggestions;

+ (BOOL)doesMatchWord:(NSString *)word {
    return [self doesMatchWordInText:word range:[word range]];
}

+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range {
    static NSRegularExpression *sharedSeperatorExpression;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSeperatorExpression = [NSRegularExpression regularExpressionWithPattern:@"^[!a-zA-Z-]+$" options:NULL error:NULL];
    });
    
    NSArray *matches = [sharedSeperatorExpression matchesInString:text options:NULL range:range];
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
    static NSArray *sharedSeperatorSuggestions;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSeperatorSuggestions = [NSArray arrayWithObjects:@".", @",", @";", nil];
    });
    
    return sharedSeperatorSuggestions;
}

@end
