//
//  JTTextView.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTTextView.h"
#import "JTTextViewMediatorDelegate.h"
#import "JTKeyboardAttachmentView.h"
#import "JTDashedBorderedView.h"
#import "JTKeyboardHeaders.h"

@interface JTTextView ()

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, assign) id<UITextViewDelegate> actualDelegate;
@property (nonatomic, retain) JTTextViewMediatorDelegate *mediatorDelegate;

- (void)setupView;

@end


@implementation JTTextView
@synthesize textController = _textController;
@synthesize actualDelegate = _actualDelegate;
@synthesize mediatorDelegate = _mediatorDelegate;
@synthesize highlightView = _highlightView;
@synthesize useSyntaxHighlighting = _useSyntaxHighlighting;
@synthesize useSyntaxCompletion = _useSyntaxCompletion;
@synthesize textSuggestionDelegate = _textSuggestionDelegate;

#pragma mark - Object lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)setupView {
    self.autocorrectionType = UITextAutocorrectionTypeNo;

    _textController = [[JTTextController alloc] init];
    _textController.delegate = self;
    
    self.useSyntaxHighlighting = YES;
    self.useSyntaxCompletion = YES;

    _mediatorDelegate = [[JTTextViewMediatorDelegate alloc] init];
    _mediatorDelegate.textView = self;
    [super setDelegate:_mediatorDelegate];
            
    self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    JTDashedBorderedView *highlightView = [[JTDashedBorderedView alloc] initWithFrame:CGRectZero];
    highlightView.backgroundColor = [UIColor clearColor];
    [self setHighlightView:highlightView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _mediatorDelegate = nil;
    _textController.delegate = nil;
    _textController = nil;
}

#pragma mark - text controller delegate actions
- (NSString *)textContent {
    return self.text;
}

- (void)replaceHighlightingWithRange:(NSRange)newRange {
    if (self.useSyntaxHighlighting) {
        if ([self.text length] == 0) {
            // in the case the text is empty the [UITextView firstRectForRange:]
            // method does not work, so we just set the frame to zero manually.
            self.highlightView.frame = CGRectMake(0, 0, 0, 0);
        } else {
            UITextRange *textRange = [self.textController textRangeFromRange:newRange];
            CGRect highlightRect = [self firstRectForRange:textRange];
            highlightRect.origin.x -= 2;
            highlightRect.size.width += 4;
            self.highlightView.frame = highlightRect;
            [self.highlightView setNeedsDisplay];
        }
    }
    // only scroll if we really select a word
    if (newRange.length != 0) {
        [self scrollRangeToVisible:newRange];
    }
}

#pragma mark - Actions forwarded to controller
- (void)didChangeText {
    // some text handling has changed since iOS7,
    // text handling should be asynchronous since then
    if (IS_BELOW_IOS7()) {
        [self.textController didChangeText];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textController didChangeText];
        });
    }
}

- (void)didChangeSelection {
    // some text handling has changed since iOS7,
    // text handling should be asynchronous since then
    if (IS_BELOW_IOS7()) {
        [self.textController didChangeSelection];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textController didChangeSelection];
        });
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // the selection is not immediately set in the textView, that's why we wait here for a certain amount of time
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textController didChangeText];
    });
    return YES;
}

- (void)moveToNextWord {
    [self.textController moveToNextWord];
}

- (void)moveToPreviousWord {
    [self.textController moveToPreviousWord];
}

- (void)moveToNextLetter {
    [self.textController moveToNextLetter];
}

- (void)moveToPreviousLetter {
    [self.textController moveToPreviousLetter];
}

- (void)selectNextSuggestion {
    [self.textController selectNextSuggestion];
}

- (void)selectPreviousSuggestion {
    [self.textController selectPreviousSuggestion];
}

- (void)selectSuggestionByIndex:(NSInteger)index {
    [self.textController selectSuggestionByIndex:index];
}

#pragma mark - overwritten methods
- (id<UITextViewDelegate>)delegate {
    return self.mediatorDelegate;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    self.actualDelegate = delegate;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    [super setInputAccessoryView:inputAccessoryView];
    if ([inputAccessoryView isKindOfClass:[JTKeyboardAttachmentView class]]) {
        self.textController.keyboardAttachmentView = (JTKeyboardAttachmentView *)inputAccessoryView;
    }
}

#pragma mark - getters & setters
- (void)setUseSyntaxCompletion:(BOOL)useSyntaxCompletion {
    [self.textController setUseSyntaxCompletion:useSyntaxCompletion];
}

- (BOOL)isSyntaxCompletionUsed {
    return [self.textController isSyntaxCompletionUsed];
}

- (id<JTTextSuggestionDelegate>)textSuggestionDelegate {
    return [self.textController textSuggestionDelegate];
}

- (void)setTextSuggestionDelegate:(id<JTTextSuggestionDelegate>)textSuggestionDelegate {
    [self.textController setTextSuggestionDelegate:textSuggestionDelegate];
}

- (void)setHighlightView:(UIView *)highlightView {
    if (_highlightView != highlightView) {
        highlightView.userInteractionEnabled = NO;
        [self addSubview:highlightView];
        _highlightView = highlightView;
    }
}

# pragma mark - orientation changes 
- (void)orientationChanged:(NSNotification *)notification{
    [self.textController triggerUpdateHighlighting];
}

@end


