//
//  NSString+Extension.m
//  Bla
//
//  Created by Alexander Koglin on 24.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "NSString+JTExtension.h"

@implementation NSString (JTExtension)

- (NSUInteger)locationOfLastWord {
    return [self rangeOfLastWord].location;
}

- (NSRange)range {
    return NSMakeRange(0, [self length]);
}

- (NSRange)rangeOfLastWord {
    return [self rangeOfLastWordAtPosition:self.length];
}

- (NSRange)rangeOfLastWordAtPosition:(NSUInteger)position {
    NSUInteger lastIndex = position-1;
    while ([NSString isSeperator:[self characterAtIndex:lastIndex]]) {
        lastIndex -= 1;
        if (lastIndex == 0) break;
    }
    
    NSUInteger indexOfLastWord = 0;
    for (NSUInteger i = lastIndex; ; i -= 1) {
        if (i == 0) {
            break;
        }
        else if ([self characterAtIndex:i] == ' ') {
            indexOfLastWord = i+1;
            break;
        }
    }
    
    return NSMakeRange(indexOfLastWord, lastIndex+1-indexOfLastWord);
}

// TODO: Handle the selection in between words
- (NSRange)rangeOfLastSeperatorsUntilPosition:(NSUInteger)position {
    NSUInteger lastIndex = position;
    while ([NSString isSeperator:[self characterAtIndex:lastIndex-1]]) {
        lastIndex -= 1;
        if (lastIndex == 0) break;
    }
    
    return NSMakeRange(lastIndex, position-lastIndex);
}

+ (BOOL)isSeperator:(unichar)letter {
    switch (letter) {
        case ' ':
        case '.':
        case ':':
            return YES; break;
            
        default:
            return NO; break;
    }
}

@end
