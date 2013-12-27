//
//  JTTextController.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextController.h"

#import "JTSyntaxWord.h"
#import "JTSyntaxLinguisticWord.h"
#import "JTSyntaxSeperatorWord.h"


@interface JTTextController ()

@property (nonatomic, readonly) NSString *textContent;
@property (nonatomic, readonly) NSRange selectionRange;
@property (nonatomic, readonly) NSRange highlightRange;

@end


@implementation JTTextController
@synthesize delegate = _delegate;

- (void)didChangeSelection {
    
}

- (void)didChangeText {
    
}

#pragma mark - internal methods
- (NSString *)textContent {
    return [self.delegate textContent];
}

- (NSRange)selectionRange {
    return [self.delegate selectionRange];
}

- (NSRange)highlightRange {
    return [self.delegate highlightRange];
}

@end
