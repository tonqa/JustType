//
//  JTTextField.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTextController.h"

@interface JTTextField : UITextField <JTTextControllerDelegate, UIGestureRecognizerDelegate>

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
