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
    return nil;
}

- (NSRange)selectionRange {
    return NSRangeFromString(@"");
}

- (NSRange)highlightRange {
    return NSRangeFromString(@"");
}

- (void)shouldSelectTextInRange:(NSRange)range {
    
}

- (void)shouldReplaceWordAtRange:(NSRange)range withWord:(NSString *)word {
    
}

- (void)shouldHighlightWordInRange:(NSRange)range {
    
}

@end
