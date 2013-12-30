//
//  JTKeyboardAttachmentView.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTSyntaxWord.h"

@class JTKeyboardAttachmentView;
@protocol JTKeyboardAttachmentViewDelegate <NSObject>

- (void)keyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView didSelectDisplayedWordWithIndex:(NSUInteger)index;

@end

@interface JTKeyboardAttachmentView : UIView

@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;
@property (nonatomic, assign) NSInteger selectedDisplayedWord;
@property (nonatomic, assign) id<JTKeyboardAttachmentViewDelegate> delegate;

@end
