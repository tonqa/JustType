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

- (void)setDisplayedWords:(NSArray *)displayedWords;

@end

@implementation JTKeyboardAttachmentView
@synthesize selectedSyntaxWord = _selectedSyntaxWord;
@synthesize selectedDisplayedWord = _selectedDisplayedWord;
@synthesize label = _label;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect labelFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.label = [[UILabel alloc] initWithFrame:labelFrame];
        self.label.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setSelectedSyntaxWord:(id<JTSyntaxWord>)syntaxWord {
    NSArray *allWords = [NSArray arrayWithObject:syntaxWord.word];
    allWords = [allWords arrayByAddingObjectsFromArray:[syntaxWord allSuggestions]];
    [self setDisplayedWords:allWords];
}

- (void)setDisplayedWords:(NSArray *)displayedWords {
    NSMutableString *wordString = [NSMutableString string];
    
    for (NSString *word in displayedWords) {
        [wordString appendFormat:@"%@  ", word];
    }
    
    [self.label setText:wordString];
    [self.label setLineBreakMode:UILineBreakModeTailTruncation];
}

@end
