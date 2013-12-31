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

- (void)setDisplayedWords:(NSArray *)displayedWords;

@end

@implementation JTKeyboardAttachmentView
@synthesize selectedSyntaxWord = _selectedSyntaxWord;
@synthesize highlightedIndex = _highlightedIndex;
@synthesize buttons = _buttons;
@synthesize label = _label;
@synthesize delegate = _delegate;

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
        [self setDisplayedWords:[NSArray array]];
    }
}

- (void)setDisplayedWords:(NSArray *)displayedWords {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    UIFont *systemFont = [UIFont systemFontOfSize:14];
    NSString *placeholderText = @"...";
    CGSize placeholderSize = [placeholderText sizeWithFont:systemFont];
    CGFloat placeholderWidth = placeholderSize.width + 10;
    
    CGFloat currentX = 0;
    NSMutableArray *wordViews = [NSMutableArray array];
    for (int i = 0; i < [displayedWords count]; i++) {
        
        NSString *displayedWord = [displayedWords objectAtIndex:i];
        CGSize textSize = [displayedWord sizeWithFont:systemFont];
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
        
        if (buttonIndex < [self.buttons count]) {
        
            UIButton *oldButton = [self.buttons objectAtIndex:oldButtonIndex];
            [oldButton setHighlighted:NO];

            UIButton *button = [self.buttons objectAtIndex:buttonIndex];
            [button setHighlighted:YES];

            _highlightedIndex = highlightedIndex;
        }
    }];
}

- (IBAction)touched:(id)sender {
    [self.delegate keyboardAttachmentView:self didSelectIndex:[((UIButton *)sender) tag]];
}

@end
