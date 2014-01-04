//
//  JTKeyboardAttachmentView.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTKeyboardAttachmentView.h"

@interface JTKeyboardAttachmentView ()

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, assign) CGFloat fontSize;

- (void)setDisplayedWords:(NSArray *)displayedWords;
- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font;

@end

@implementation JTKeyboardAttachmentView
@synthesize selectedSyntaxWord = _selectedSyntaxWord;
@synthesize highlightedIndex = _highlightedIndex;
@synthesize buttons = _buttons;
@synthesize label = _label;
@synthesize delegate = _delegate;
@synthesize fontSize = _fontSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelectedSyntaxWord:(id<JTSyntaxWord>)syntaxWord {
    if (syntaxWord) {
        NSArray *allWords = [NSArray arrayWithObject:syntaxWord.word];
        allWords = [allWords arrayByAddingObjectsFromArray:[syntaxWord allSuggestions]];
        [self setDisplayedWords:allWords];
    } else {
        [self setDisplayedWords:nil];
    }
}

- (void)setDisplayedWords:(NSArray *)displayedWords {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }

    if (!displayedWords) {
        NSString *notAvailableText = @"suggestion is not possible";
        UIFont *notAvailableFont = [UIFont italicSystemFontOfSize:self.fontSize];
        CGSize notAvailableSize = [self sizeOfText:notAvailableText withFont:notAvailableFont];
        CGRect notAvailableRect = CGRectMake(20, 0, notAvailableSize.width, self.frame.size.height);
        UILabel *notAvailableLabel = [[UILabel alloc] initWithFrame:notAvailableRect];
        notAvailableLabel.text = notAvailableText;
        notAvailableLabel.font = notAvailableFont;
        notAvailableLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:notAvailableLabel];
    }
    
    
    UIFont *systemFont = [UIFont systemFontOfSize:self.fontSize];
    NSString *placeholderText = @"...";
    CGSize placeholderSize = [self sizeOfText:placeholderText withFont:systemFont];
    CGFloat placeholderWidth = placeholderSize.width + 10;
    
    CGFloat currentX = 0;
    NSMutableArray *wordViews = [NSMutableArray array];
    for (int i = 0; i < [displayedWords count]; i++) {
        
        NSString *displayedWord = [displayedWords objectAtIndex:i];
        CGSize textSize = [self sizeOfText:displayedWord withFont:systemFont];
        CGFloat buttonWidth = textSize.width + 20;
        
        if (currentX+buttonWidth+placeholderWidth > self.frame.size.width) {
            
            CGRect labelRect = CGRectMake(currentX + 5, 0, placeholderSize.width, self.frame.size.height);
            UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:labelRect];
            placeholderLabel.text = placeholderText;
            placeholderLabel.font = systemFont;
            [self addSubview:placeholderLabel];
            
            break;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button.titleLabel setFont:systemFont];
        [button setTag:i-1];
        [button setTitle:displayedWord forState:UIControlStateNormal];
        [button setFrame:CGRectMake(currentX, 0, buttonWidth, self.frame.size.height)];
        [button addTarget:self action:@selector(touched:) forControlEvents:UIControlEventTouchUpInside];
        
        currentX += buttonWidth;
        
        [self addSubview:button];
        [wordViews addObject:button];
    }
    
    self.buttons = wordViews;
}

- (void)setHighlightedIndex:(NSInteger)highlightedIndex {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSInteger oldButtonIndex = _highlightedIndex+1;
        NSInteger buttonIndex = highlightedIndex+1;
        
        if (oldButtonIndex < [self.buttons count]) {
            UIButton *oldButton = [self.buttons objectAtIndex:oldButtonIndex];
            [oldButton setHighlighted:NO];
        }

        if (buttonIndex < [self.buttons count]) {
            UIButton *button = [self.buttons objectAtIndex:buttonIndex];
            [button setHighlighted:YES];
        }

        _highlightedIndex = highlightedIndex;
    }];
}

- (IBAction)touched:(id)sender {
    [self.delegate keyboardAttachmentView:self didSelectIndex:[((UIButton *)sender) tag]];
}

# pragma mark - helper methods
- (CGFloat)fontSize {
    if (!_fontSize) {
        _fontSize = [self fontSizeForRectHeight:MAX(0, self.frame.size.height - 15)];
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

@end
