//
//  JTTextField.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextField.h"

@interface JTTextField ()

@property (nonatomic, retain) JTTextController *textController;

@end


@implementation JTTextField
@synthesize textController = _textController;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textController = [[JTTextController alloc] init];
        _textController.delegate = self;
    }
    return self;
}

- (void)dealloc {
    _textController.delegate = nil;
    _textController = nil;
}

- (NSString *)textContent {
    return self.text;
}

- (void)highlightWord:(BOOL)shouldBeHighlighted inRange:(NSRange)range {
//    NSMutableAttributedString *highlightedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//    [highlightedString addAttribute: NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
//    [textView setAttributedText:highlightedString];
}

@end
