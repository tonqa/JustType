//
//  JTTextView.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTextController.h"

@interface JTTextView : UITextView <JTTextControllerDelegate>

@property (nonatomic, assign, getter = isSyntaxHighlightingUsed) BOOL useSyntaxHighlighting;
@property (nonatomic, assign, getter = isSyntaxCompletionUsed) BOOL useSyntaxCompletion;

@property (nonatomic, retain) UIView *highlightView;
@property (nonatomic, assign) id<JTTextSuggestionDelegate> textSuggestionDelegate;

- (void)selectSuggestionByIndex:(NSInteger)index;

@end
