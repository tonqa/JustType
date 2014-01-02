//
//  JTTextController.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTKeyboardAttachmentView.h"

@class JTKeyboardAttachmentView;
@protocol JTTextControllerDelegate <NSObject>

- (NSString *)textContent;

- (void)replaceHighlightingWithRange:(NSRange)newRange;

@end


@interface JTTextController : NSObject <JTKeyboardAttachmentViewDelegate>

@property (nonatomic, retain) JTKeyboardAttachmentView *keyboardAttachmentView;
@property (nonatomic, assign) UIResponder<JTTextControllerDelegate, UITextInput> *delegate;

- (void)didChangeSelection;
- (void)didChangeText;

- (UITextRange *)textRangeFromRange:(NSRange)range;

@end
