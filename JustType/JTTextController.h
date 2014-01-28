//
//  JTTextController.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTKeyboardAttachmentView.h"
#import "JTTextSuggestionDelegate.h"

@class JTKeyboardAttachmentView;

/**
 *  The delegate of the textController must be implemented by the view, which displays the text.
 */
@protocol JTTextControllerDelegate <NSObject>

/**
 *  The text input should return its displayed textContent.
 *
 *  @return the text that is in the view
 */
- (NSString *)textContent;

/**
 *  The text input should highlight its text.
 *
 *  @param newRange The range of the text that should be highlighted
 */
- (void)replaceHighlightingWithRange:(NSRange)newRange;

@end


/**
 *  This is the main class for text navigation. Every text input element must have an instance of this textController. It is responsible for identifying, selecting and highlighting words, as well as for identifying suggestions.
 */
@interface JTTextController : NSObject <JTKeyboardAttachmentViewDelegate>

/**
 *  Flag tells if making suggestions should be activated.
 */
@property (nonatomic, assign, getter = isSyntaxCompletionUsed) BOOL useSyntaxCompletion;

/**
 *  The default attachment for the keyboard to make suggestions.
 */
@property (nonatomic, retain) JTKeyboardAttachmentView *keyboardAttachmentView;

/**
 *  The delegate is a view element which modifies text, derives from UIResponder and corresponds to the UITextInput as well as the JTTextControllerDelegate protocols.
 */
@property (nonatomic, assign) UIResponder<UITextInput, JTTextControllerDelegate> *delegate;

/**
 *  An option delegate that can be set if own suggestions shall be displayed.
 */
@property (nonatomic, assign) id<JTTextSuggestionDelegate> textSuggestionDelegate;

/**
 *  The text input element is responsible for telling if its selection has changed and must then call this method.
 */
- (void)didChangeSelection;

/**
 *  The text input element is responsible for telling if its text content has changed and must then call this method.
 */
- (void)didChangeText;

/**
 *  This is a utility method for converting an NSRange into a UITextRange.
 *
 *  @param range The NSRange object
 *
 *  @return The converted UITextRange object
 */
- (UITextRange *)textRangeFromRange:(NSRange)range;

- (void)triggerUpdateHighlighting;

/**
 *  This triggers the text element to move the cursor to the previous word. If it does not exist the cursor just stays where it was.
 */
- (void)moveToPreviousWord;

/**
 *  This triggers the text element to move the cursor to the next word.
 */
- (void)moveToNextWord;

/**
 *  This triggers the text element to move the cursor to the previous letter. If it does not exist the cursor just stays where it was.
 */
- (void)moveToPreviousLetter;

/**
 *  This triggers the text element to move the cursor to the next letter.
 */
- (void)moveToNextLetter;

/**
 *  This triggers the text element to select the previous suggestion.
 */
- (void)selectPreviousSuggestion;

/**
 *  This triggers the text element to select the next suggestion.
 */
- (void)selectNextSuggestion;

/**
 *  This triggers the text element to select a suggestion with a suggestion index. The index can be -1 if no suggestion should be selected.
 *
 *  @param index suggestion index that sets the selected suggestion of this word
 */
- (void)selectSuggestionByIndex:(NSInteger)index;

@end
