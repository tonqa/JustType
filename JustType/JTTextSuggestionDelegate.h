//
//  JTTextSuggestionDelegate.h
//  JustType
//
//  Created by Alexander Koglin on 03.01.14.
//
//

#import <Foundation/Foundation.h>

/**
 *  Delegate protocol, which can be installed on the JTTextField and the JTTextView in order to react to word selection and suggestion changes.
 */
@protocol JTTextSuggestionDelegate <NSObject>

@optional
/**
 *  Called after another word was selected by the user of the text input element. Initially no suggestion is chosen for the selected word.
 *
 *  @param word        The string which was selected
 *  @param range       The range where the string is inside the text
 *  @param suggestions The suggestions which are possible for this word
 */
- (void)didSelectWord:(NSString *)word atRange:(NSRange)range suggestions:(NSArray *)suggestions;

/**
 *  Called after another suggestion was chosen for the currently selected word. The selected word still stays the same.
 *
 *  @param selectedIndex The index of the chosen suggestion
 */
- (void)didSelectSuggestionIndex:(NSInteger)selectedIndex;

/**
 *  Called if all selections were revoked, such that no word is selected any more.
 */
- (void)didClearSelection;

@end
