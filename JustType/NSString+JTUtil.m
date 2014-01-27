//
//  NSString+JTUtil.m
//  JustType
//
//  Created by Alexander Koglin on 27.01.14.
//
//

#import "NSString+JTUtil.h"

@implementation NSString (JTUtil)

- (BOOL)beginsWithUpperCaseLetter {
    NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    return [upperCaseSet characterIsMember:[self characterAtIndex:0]];
}

@end
