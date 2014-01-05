//
//  JTTextViewMediatorDelegate.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTTextViewMediatorDelegate.h"
#import "JTTextView.h"

@interface JTTextView (JTTextViewMediatorDelegate)

- (id<UITextViewDelegate>)actualDelegate;
- (void)didChangeSelection;
- (void)didChangeText;
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;

@end

@implementation JTTextViewMediatorDelegate
@synthesize textView;

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    BOOL result = [self.textView textViewShouldBeginEditing:self.textView];
    if ([self.textView.actualDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        result = [self.textView.actualDelegate textViewShouldBeginEditing:self.textView];
    }
    return result;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.textView didChangeText];
    if ([self.textView.actualDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.textView.actualDelegate textViewDidChange:self.textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self.textView didChangeSelection];
    if ([self.textView.actualDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.textView.actualDelegate textViewDidChangeSelection:self.textView];
    }
}

// forward everything else to delegate
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.textView.actualDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.textView.actualDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
