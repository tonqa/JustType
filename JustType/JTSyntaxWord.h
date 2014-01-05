//
//  JTSyntaxWord.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JTSyntaxWord <NSObject>

+ (BOOL)doesMatchWord:(NSString *)word;
+ (BOOL)doesMatchWordInText:(NSString *)text range:(NSRange)range;

+ (id)alloc;
- (id)initWithText:(NSString *)text inRange:(NSRange)range useSuggestions:(BOOL)shouldUseSuggestions textInputMode:(UITextInputMode *)textInputMode;

- (NSString *)word;
- (NSArray *)allSuggestions;

@end
