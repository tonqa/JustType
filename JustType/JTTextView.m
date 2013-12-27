//
//  JTTextView.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextView.h"


@interface JTTextView ()

@property (nonatomic, retain) JTTextController *textController;

@end


@implementation JTTextView
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
}

@end
