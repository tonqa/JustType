//
//  JTTextView.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTextController.h"

@interface JTTextView : UITextView <JTTextControllerDelegate>

@property (nonatomic, assign, getter = isSyntaxHighlightingUsed) BOOL useSyntaxHighlighting;
@property (nonatomic, assign, getter = isSyntaxCompletionUsed) BOOL useSyntaxCompletion;

@property (nonatomic, retain) UIView *highlightView;
@property (nonatomic, assign) id<JTTextSuggestionDelegate> textSuggestionDelegate;

- (void)moveToPreviousWord;
- (void)moveToNextWord;
- (void)moveToPreviousLetter;
- (void)moveToNextLetter;
- (void)selectPreviousSuggestion;
- (void)selectNextSuggestion;
- (void)selectSuggestionByIndex:(NSInteger)index;

@end
