//
//  JTKeyboardAttachmentView.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTSyntaxWord.h"

@class JTKeyboardAttachmentView;

/**
 *  A delegate which informs the user of the attachment view that a certain suggestion with an index was clicked.
 */
@protocol JTKeyboardAttachmentViewDelegate <NSObject>

/**
 *  This informs the user of the attachment view that a certain suggestion with an index was clicked.
 *
 *  @param attachmentView the attachment view at which this event occured
 *  @param index          the index of the suggestion that was touched (if it is -1 then no suggestion was chosen)
 */
- (void)keyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView didSelectIndex:(NSInteger)index;

- (void)switchcaseForKeyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView;

@end

/**
 *  The attachment view that is displayed on top of the keyboard. It is just a clear / transparent color view, which displays visual helps for gestures on top of it. The visual helps are arrows showing into the direction of the swipe.
 */
@interface JTKeyboardAttachmentView : UIView

/**
 *  The currently selected syntax word of this view. The syntax word includes the word itself and any possible suggestions for this word.
 */
@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;

/**
 *  The currently selected suggestion by index. If it is -1 then no suggestion was chosen.
 */
@property (nonatomic, assign) NSInteger highlightedIndex;

/**
 *  The delegate that gets informed if another suggestion (with another index) is chosen by the user of the view.
 */
@property (nonatomic, assign) id<JTKeyboardAttachmentViewDelegate> delegate;

@end
