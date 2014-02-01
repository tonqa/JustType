//
//  JTSyntaxWord.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Protocol for describing a word unit having a text and suggestions.
 */
@protocol JTSyntaxWord <NSObject>

/**
 *  This checks if this syntax word can be applied to the word with the range inside the text of the text input element.
 *
 *  @param text  the complete text of the text input element
 *  @param range the range in which the word can be found
 *
 *  @return the boolean value that tells if the syntax applied to the word
 */
+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range;

/**
 *  This is the initializer for a syntax word with all required fields.
 *
 *  @param text                 the text of the whole text input element
 *  @param range                the range in which the syntax word is inside the text
 *  @param shouldUseSuggestions a flag indicating if suggestions are needed and shall be computed
 *  @param textInputMode        the activated text input mode of the keyboard, which determines the language for possible translations
 *
 *  @return a syntax word with computed suggestions
 */
- (id)initWithText:(NSString *)text inRange:(NSRange)range useSuggestions:(BOOL)shouldUseSuggestions isCurrentlyWritingWord:(BOOL)isCurrentlyWritingWord textInputMode:(UITextInputMode *)textInputMode;

+ (id)alloc;

/**
 *  This returns the text of the syntax word unit.
 *
 *  @return text of the syntax word
 */
- (NSString *)text;

/**
 *  Describes all suggestions for this word unit.
 *
 *  @return a list of suggestions for the word
 */
- (NSArray *)allSuggestions;

/**
 *  Tells if the word can be turned from upper to lower case and back
 *
 *  @return a boolean which tells if capitalization is possible
 */
- (BOOL)canBeCapitalized;

@end
