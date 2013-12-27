//
//  JTSyntaxSeperatorWord.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTSyntaxSeperatorWord.h"

@implementation JTSyntaxSeperatorWord

+ (BOOL)matchWord:(NSString *)word {
    return NO;
}

- (id)initWithWord:(NSString *)word {
    return [super init];
}

- (NSInteger)indexOfCurrentSuggestion {
    return -1;
}

- (NSArray *)allSuggestions {
    return [NSArray array];
}

@end
