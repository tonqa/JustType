//
//  JTKeyboardAttachmentView.m
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import "JTKeyboardAttachmentView.h"
#import "JTEdgeInsetLabel.h"
#import "NSString+JTUtil.h"

#define JTKEYBOARD_ATTACHMENT_SPACING 12.0

@interface JTKeyboardAttachmentView ()

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, retain) NSArray *allButtons;
@property (nonatomic, retain) UIButton *upButton;
@property (nonatomic, retain) JTEdgeInsetLabel *notAvailableLabel;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) NSNumber *currentStopPage;

- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font;

@end

@implementation JTKeyboardAttachmentView
@synthesize selectedSyntaxWord = _selectedSyntaxWord;
@synthesize highlightedIndex = _highlightedIndex;
@synthesize allButtons = _allButtons;
@synthesize delegate = _delegate;
@synthesize fontSize = _fontSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.highlightedIndex = -1;
    }
    return self;
}

#pragma mark - public methods
- (void)setSelectedSyntaxWord:(id<JTSyntaxWord>)syntaxWord {
    _highlightedIndex = -1;
    _selectedSyntaxWord = syntaxWord;
    
    if (syntaxWord) {
        NSMutableArray *allWords = [NSMutableArray arrayWithObject:syntaxWord.text];
        [allWords addObjectsFromArray:[syntaxWord allSuggestions]];
        NSMutableArray *allButtons = [NSMutableArray arrayWithCapacity:allWords.count];
        
        for (int i = 0; i < allWords.count; i++) {
            NSString *text = [allWords objectAtIndex:i];
            UIButton *button = [self createButtonWithText:text tag:i];
            [allButtons addObject:button];
        }
        
        _allButtons = [allButtons copy];
    } else {
        _allButtons = nil;
    }

    self.currentStopPage = nil;
    [self setNeedsLayout];
}

- (void)setHighlightedIndex:(NSInteger)highlightedIndex {
    NSInteger oldButtonIndex = _highlightedIndex+1;
    UIButton *oldButton = [self.allButtons objectAtIndex:oldButtonIndex];
    [oldButton setHighlighted:NO];
    
    NSInteger newButtonIndex = highlightedIndex+1;
    UIButton *newButton = [self.allButtons objectAtIndex:newButtonIndex];
    [newButton setHighlighted:YES];
    
    _highlightedIndex = highlightedIndex;
    self.currentStopPage = nil;
    [self setNeedsLayout];
}

#pragma mark - actions
- (IBAction)touchedWord:(UIButton *)sender {
    [self.delegate keyboardAttachmentView:self didSelectIndex:sender.tag-1];
}

- (IBAction)touchedLastPage:(id)sender {
    self.currentStopPage = @(self.currentPage-1);
    [self setNeedsLayout];
}

- (IBAction)touchedNextPage:(id)sender {
    self.currentStopPage = @(self.currentPage+1);
    [self setNeedsLayout];
}

- (IBAction)switchcase:(id)sender {
    [self.delegate switchcaseForKeyboardAttachmentView:self];
}

# pragma mark - helper methods
- (CGFloat)fontSize {
    if (!_fontSize) {
        _fontSize = [self fontSizeForRectHeight:MAX(0, self.frame.size.height - JTKEYBOARD_ATTACHMENT_SPACING)];
    }
    return _fontSize;
}

- (CGFloat)fontSizeForRectHeight:(CGFloat)height {
    UIFont *font = nil;
    for (float i = height; i > 0; i = i - 1) {
        font = [UIFont systemFontOfSize:i];
        if ([font lineHeight] < height) break;
    }
    if ([font respondsToSelector:@selector(fontDescriptor)]) {
        return [[font fontDescriptor] pointSize];
    }
    // this is for compatibility reasons up to iOS 6
    return [font pointSize];
}

/**
 * These checks are for compatibility purposes for iOS6
 */
- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font {
    CGSize size;
    if ([text respondsToSelector:@selector(sizeWithAttributes:)]) {
        size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    } else {
        SEL aSelector = @selector(sizeWithFont:);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[text methodSignatureForSelector:aSelector]];
        
        [invocation setTarget:text];
        [invocation setSelector:aSelector];
        [invocation setArgument:&font atIndex:2];
        [invocation invoke];
        [invocation getReturnValue:&size];
    }
    return size;
}

- (UIButton *)createButtonWithText:(NSString *)text tag:(NSInteger)index {
    UIFont *systemFont = [UIFont systemFontOfSize:self.fontSize];
    CGSize textSize = [self sizeOfText:text withFont:systemFont];
    CGFloat buttonWidth = textSize.width + 20;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button.titleLabel setFont:systemFont];
    [button setTag:index];
    [button setTitle:text forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, buttonWidth, self.frame.size.height)];
    [button addTarget:self action:@selector(touchedWord:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - getters & setters
- (UIButton *)upButton {
    NSString *capitalizeArrowText = [self capitalizeButtonText];
    if (!_upButton) {
        
        // the unicode char is smaller, thus we add eight points
        UIFont *capitalizeFont = [UIFont systemFontOfSize:self.fontSize];
        CGSize textSize = [self sizeOfText:capitalizeArrowText
                                  withFont:capitalizeFont];
        CGFloat upButtonWidth = textSize.width + 40;
        
        _upButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _upButton.frame = CGRectMake(0, 0, upButtonWidth, 0);
        _upButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10);
        [_upButton.titleLabel setFont:capitalizeFont];
        [_upButton setTitle:capitalizeArrowText forState:UIControlStateNormal];
        [_upButton addTarget:self action:@selector(switchcase:)
           forControlEvents:UIControlEventTouchUpInside];
    }
    [_upButton setTitle:capitalizeArrowText forState:UIControlStateNormal];
    return _upButton;
}

- (UILabel *)notAvailableLabel {
    if (!_notAvailableLabel) {
        NSString *notAvailableText = @"suggestion is not possible";
        UIFont *notAvailableFont = [UIFont italicSystemFontOfSize:self.fontSize];
        CGSize notAvailableSize = [self sizeOfText:notAvailableText
                                          withFont:notAvailableFont];
        CGRect notAvailableRect = CGRectMake(0, 0, notAvailableSize.width+10,
                                             self.frame.size.height);
        
        _notAvailableLabel = [[JTEdgeInsetLabel alloc] initWithFrame:notAvailableRect];
        _notAvailableLabel.text = notAvailableText;
        _notAvailableLabel.font = notAvailableFont;
        _notAvailableLabel.textColor = [UIColor lightGrayColor];
        _notAvailableLabel.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    return _notAvailableLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        UIFont *systemFont = [UIFont systemFontOfSize:self.fontSize];
        NSString *placeholderText = @"...";
        CGSize placeholderSize = [self sizeOfText:placeholderText withFont:systemFont];
        
        _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _backButton.frame = CGRectMake(0, 0, placeholderSize.width+10, 0);
        _backButton.titleLabel.font = systemFont;
        _backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [_backButton setTitle:placeholderText forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(touchedLastPage:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        UIFont *systemFont = [UIFont systemFontOfSize:self.fontSize];
        NSString *placeholderText = @"...";
        CGSize placeholderSize = [self sizeOfText:placeholderText withFont:systemFont];
        
        _nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _nextButton.frame = CGRectMake(0, 0, placeholderSize.width+10, 0);
        _nextButton.titleLabel.font = systemFont;
        _nextButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [_nextButton setTitle:placeholderText forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(touchedNextPage:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (NSString *)capitalizeButtonText {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return @"^ ";
    } else {
        if ([self.selectedSyntaxWord.text beginsWithUpperCaseLetter]) {
            return @"\u2193";
        } else {
            return @"\u2191";
        }
    }
}

#pragma mark - layouting
- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    if (!self.allButtons) {
        [self addSubview:self.notAvailableLabel];
        return;
    }
    
    CGFloat upButtonWidth = 0.0f;
    if (self.selectedSyntaxWord.canBeCapitalized) {
        upButtonWidth = self.upButton.frame.size.width;
        self.upButton.frame = CGRectMake(self.frame.size.width-upButtonWidth, 0,
                                         upButtonWidth, self.frame.size.height);
        [self addSubview:self.upButton];
    }
    
    CGFloat xPos = 0;
    CGFloat pageNo = 0;
    BOOL foundHighlightedIndex = NO;
    BOOL isFirstPage = YES;
    
    UIButton *button;
    CGFloat buttonWidth, summedUpWidth;
    CGFloat backButtonWidth = 0.0f;
    CGFloat nextButtonWidth = self.nextButton.frame.size.width;
    
    NSMutableArray *displayedButtons = [NSMutableArray array];
    for (int index = 0; index < [self.allButtons count]; index++) {
        
        button = [self.allButtons objectAtIndex:index];
        buttonWidth = button.frame.size.width;
        
        //if it is the last button then 'no next button' (width is 0)
        if (index+1 != [self.allButtons count]) {
            nextButtonWidth = 0.0f;
        }
        
        summedUpWidth = xPos + backButtonWidth + buttonWidth +
        nextButtonWidth + upButtonWidth;
        
        BOOL buttonDoesFit = (summedUpWidth <= self.frame.size.width);
        if (!buttonDoesFit) {
            
            // if we found stop page or highlighted index then quit
            // else increase page number and go on
            if ((self.currentStopPage && pageNo == [self.currentStopPage integerValue]) ||
                (!self.currentStopPage && foundHighlightedIndex)) {
                
                break;
                
            } else {
                xPos = 0.0f;
                pageNo++;
                isFirstPage = NO;
                displayedButtons = [NSMutableArray array];
                backButtonWidth = self.backButton.frame.size.width;
            }
        }
        
        // this adds the button
        BOOL buttonIsHighlighted = (index == self.highlightedIndex+1);
        if (buttonIsHighlighted) {
            // we need to set highlighted state again
            // because it was lost when removeFromSuperView was called.
            [button setHighlighted:YES];
        }
        foundHighlightedIndex = foundHighlightedIndex || buttonIsHighlighted;
        button.frame = CGRectMake(xPos + backButtonWidth, 0.0f,
                                  button.frame.size.width,
                                  self.frame.size.height);
        [displayedButtons addObject:button];
        xPos += buttonWidth;
    }
    
    for (UIButton *displayedButton in displayedButtons) {
        [self addSubview:displayedButton];
    }
    
    // not on first page => back button
    if (!isFirstPage) {
        self.backButton.frame = CGRectMake(0, 0, self.backButton.frame.size.width,
                                           self.frame.size.height);
        [self addSubview:self.backButton];
    }
    
    // not on last page => next button
    if (self.allButtons.lastObject != displayedButtons.lastObject) {
        self.nextButton.frame = CGRectMake(xPos + backButtonWidth, 0,
                                           self.nextButton.frame.size.width,
                                           self.frame.size.height);
        [self addSubview:self.nextButton];
    }
    
    self.currentPage = pageNo;
}

@end
