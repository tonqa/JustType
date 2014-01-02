//
//  JTTextView.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextView.h"
#import "JTTextViewMediatorDelegate.h"
#import "JTKeyboardAttachmentView.h"
#import "NSString+JTExtension.h"

@interface JTTextView ()

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *pressGesture;

@property (nonatomic, assign) id<UITextViewDelegate> actualDelegate;
@property (nonatomic, retain) JTTextViewMediatorDelegate *mediatorDelegate;

@property (nonatomic, assign) BOOL isIgnoringUpdates;

@end


@implementation JTTextView
@synthesize textController = _textController;
@synthesize tapGesture = _tapGesture;
@synthesize pressGesture = _pressGesture;

@synthesize actualDelegate = _actualDelegate;
@synthesize mediatorDelegate = _mediatorDelegate;
@synthesize isIgnoringUpdates = _isIgnoringUpdates;

#pragma mark - Object lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;

        _textController = [[JTTextController alloc] init];
        _textController.delegate = self;
        
        _mediatorDelegate = [[JTTextViewMediatorDelegate alloc] init];
        _mediatorDelegate.textView = self;
        [super setDelegate:_mediatorDelegate];
                
        self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
    return self;
}

- (void)dealloc {
    _mediatorDelegate = nil;
    _textController.delegate = nil;
    _textController = nil;
}

#pragma mark - text controller delegate actions
- (NSString *)textContent {
    return self.text;
}

- (void)replaceHighlightingWithRange:(NSRange)newRange {
#ifdef __IPHONE_6_0
    // these checks are for compatibility reasons with older iOS versions
    if ([self respondsToSelector:@selector(setAttributedText:)]) {
        NSMutableAttributedString *highlightedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [highlightedString removeAttribute:NSForegroundColorAttributeName range:self.text.range];
        [highlightedString addAttribute: NSForegroundColorAttributeName value:[UIColor grayColor] range:newRange];
        [self setAttributedText:highlightedString];
    }
#endif
}

#pragma mark - Overwritten methods
- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    [super setInputAccessoryView:inputAccessoryView];
    if ([inputAccessoryView isKindOfClass:[JTKeyboardAttachmentView class]]) {
        self.textController.keyboardAttachmentView = (JTKeyboardAttachmentView *)inputAccessoryView;
    }
}

#pragma mark - Actions forwarded to controller
- (void)didChangeText {
    [self.textController didChangeText];
}

- (void)didChangeSelection {
    [self.textController didChangeSelection];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textController didChangeText];
    });
    return YES;
}

#pragma mark - overwritten methods
- (id<UITextViewDelegate>)delegate {
    return self.mediatorDelegate;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    self.actualDelegate = delegate;
}

@end


