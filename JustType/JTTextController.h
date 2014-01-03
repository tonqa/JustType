//
//  JTTextController.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTKeyboardAttachmentView.h"
#import "JTTextSuggestionDelegate.h"

@class JTKeyboardAttachmentView;
@protocol JTTextControllerDelegate <NSObject>

- (NSString *)textContent;

- (void)replaceHighlightingWithRange:(NSRange)newRange;

@end


@interface JTTextController : NSObject <JTKeyboardAttachmentViewDelegate>

@property (nonatomic, assign, getter = isSyntaxCompletionUsed) BOOL useSyntaxCompletion;

@property (nonatomic, retain) JTKeyboardAttachmentView *keyboardAttachmentView;
@property (nonatomic, assign) UIResponder<JTTextControllerDelegate, UITextInput> *delegate;
@property (nonatomic, assign) id<JTTextSuggestionDelegate> textSuggestionDelegate;

- (void)didChangeSelection;
- (void)didChangeText;

- (UITextRange *)textRangeFromRange:(NSRange)range;

- (void)moveToPreviousWord;
- (void)moveToNextWord;
- (void)moveToPreviousLetter;
- (void)moveToNextLetter;
- (void)selectPreviousSuggestion;
- (void)selectNextSuggestion;
- (void)selectSuggestionByIndex:(NSInteger)index;

@end
