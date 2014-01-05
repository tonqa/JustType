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
@protocol JTKeyboardAttachmentViewDelegate <NSObject>

- (void)keyboardAttachmentView:(JTKeyboardAttachmentView *)attachmentView didSelectIndex:(NSInteger)index;

@end

@interface JTKeyboardAttachmentView : UIView

@property (nonatomic, retain) id<JTSyntaxWord> selectedSyntaxWord;
@property (nonatomic, assign) NSInteger highlightedIndex;
@property (nonatomic, assign) id<JTKeyboardAttachmentViewDelegate> delegate;

@end
