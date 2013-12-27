//
//  JTSyntaxWord.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JTSyntaxWord <NSObject>

+ (BOOL)matchWord:(NSString *)word;

- (id)initWithWord:(NSString *)word;

- (NSInteger)indexOfCurrentSuggestion;
- (NSArray *)allSuggestions;

@end
