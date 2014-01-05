//
//  NSString+Extension.h
//  Bla
//
//  Created by Alexander Koglin on 24.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JTExtension)

- (NSUInteger)locationOfLastWord;
- (NSRange)range;
- (NSRange)rangeOfLastWord;
- (NSRange)rangeOfLastWordAtPosition:(NSUInteger)position;
- (NSRange)rangeOfLastSeperatorsUntilPosition:(NSUInteger)position;

+ (BOOL)isSeperator:(unichar)letter;

@end
