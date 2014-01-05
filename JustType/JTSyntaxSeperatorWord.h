//
//  JTSyntaxSeperatorWord.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTSyntaxWord.h"

/**
 *  A syntax word which can be applied to all seperator tokens or characters like commas, dots, question marks and so on.
 */
@interface JTSyntaxSeperatorWord : NSObject<JTSyntaxWord>

/**
 *  The suggestions, which are proposed for all seperator words.
 *
 *  @return suggestions that are possible for seperator words
 */
+ (NSArray *)possibleSuggestions;

@end
