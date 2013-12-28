//
//  JTSyntaxWord.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JTSyntaxWord <NSObject>

+ (BOOL)doesMatchWord:(NSString *)word;
+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range;

+ (id)alloc;
- (id)initWithText:(NSString *)text inRange:(NSRange)range;

- (NSString *)word;
- (NSArray *)allSuggestions;

@end
