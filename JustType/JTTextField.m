//
//  JTTextField.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <objc/runtime.h>
#import "JTTextField.h"
#import "JTTextFieldMediatorDelegate.h"
#import "JTDashedBorderedView.h"
#import "JTKeyboardHeaders.h"

UIKIT_STATIC_INLINE void mySelectionDidChange(id self, SEL _cmd, id<UITextInput> textInput);

@interface JTTextField ()

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *pressGesture;
@property (nonatomic, assign) id<UITextFieldDelegate> actualDelegate;
@property (nonatomic, retain) JTTextFieldMediatorDelegate *mediatorDelegate;

- (void)setupView;

@end


@implementation JTTextField
@synthesize textController = _textController;
@synthesize tapGesture = _tapGesture;
@synthesize pressGesture = _pressGesture;
@synthesize actualDelegate = _actualDelegate;
@synthesize mediatorDelegate = _mediatorDelegate;
@synthesize useSyntaxHighlighting = _useSyntaxHighlighting;
@synthesize useSyntaxCompletion = _useSyntaxCompletion;
@synthesize textSuggestionDelegate = _textSuggestionDelegate;
@synthesize unhighlightedColor = _unhighlightedColor;
@synthesize highlightedColor = _highlightedColor;

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
    }
    return self;
}

- (void)setupView {
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _unhighlightedColor = [UIColor blackColor];
    _highlightedColor = [UIColor grayColor];
    _textController = [[JTTextController alloc] init];
    _textController.delegate = self;
    
    self.useSyntaxHighlighting = YES;
    self.useSyntaxCompletion = YES;
    
    _mediatorDelegate = [[JTTextFieldMediatorDelegate alloc] init];
    _mediatorDelegate.textField = self;
    [super setDelegate:_mediatorDelegate];
    
    [self addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(didSingleTap:)];
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
    
    UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] init];
    [pressGesture addTarget:self action:@selector(didSingleTap:)];
    pressGesture.cancelsTouchesInView = YES;
    pressGesture.delegate = self;
    [self addGestureRecognizer:pressGesture];
    self.pressGesture = pressGesture;
}

- (void)dealloc {
    [self.tapGesture.view removeGestureRecognizer:self.tapGesture];
    [self.pressGesture.view removeGestureRecognizer:self.pressGesture];
    
    [self removeTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    _textController.delegate = nil;
    _textController = nil;
    _mediatorDelegate = nil;
}

#pragma mark - text controller delegate actions
- (NSString *)textContent {
    return self.text;
}

- (void)replaceHighlightingWithRange:(NSRange)newRange {
    if (self.useSyntaxHighlighting) {
        NSMutableAttributedString *highlightedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        NSRange wordLength = NSMakeRange(0, [highlightedString.string length]);
        //[highlightedString removeAttribute:NSForegroundColorAttributeName range:highlightedString.string.range];
        [highlightedString addAttribute:NSForegroundColorAttributeName value:self.unhighlightedColor range:wordLength];
        [highlightedString addAttribute:NSForegroundColorAttributeName value:self.highlightedColor range:newRange];
        [self setAttributedText:highlightedString];
    }
}

#pragma mark - Actions forwarded to controller
- (void)didChangeText:(id)sender {
    if (IS_BELOW_IOS7()) {
        [self.textController didChangeText];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textController didChangeText];
        });
    }
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

#pragma mark - Gesture recognizer actions
- (void)didSingleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textController didChangeSelection];
        });
    }
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - overwritten methods
- (id<UITextFieldDelegate>)delegate {
    return self.mediatorDelegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    self.actualDelegate = delegate;
}

- (id<JTTextSuggestionDelegate>)textSuggestionDelegate {
    return [self.textController textSuggestionDelegate];
}

- (void)setTextSuggestionDelegate:(id<JTTextSuggestionDelegate>)textSuggestionDelegate {
    [self.textController setTextSuggestionDelegate:textSuggestionDelegate];
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    [super setInputAccessoryView:inputAccessoryView];
    if ([inputAccessoryView isKindOfClass:[JTKeyboardAttachmentView class]]) {
        self.textController.keyboardAttachmentView = (JTKeyboardAttachmentView *)inputAccessoryView;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // the selection is not immediately set in the textField, that's why we wait here for a certain amount of time
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textController didChangeText];
    });
    return YES;
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textController didChangeText];
    });
}

#pragma mark - getters & setters
- (void)setUseSyntaxCompletion:(BOOL)useSyntaxCompletion {
    [self.textController setUseSyntaxCompletion:useSyntaxCompletion];
}

- (BOOL)isSyntaxCompletionUsed {
    return [self.textController isSyntaxCompletionUsed];
}

@end
