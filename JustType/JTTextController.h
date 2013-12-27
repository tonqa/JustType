//
//  JTTextController.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JTTextControllerDelegate <NSObject>

- (NSString *)textContent;
- (NSRange)selectionRange;
- (NSRange)highlightRange;

- (void)shouldSelectTextInRange:(NSRange)range;
- (void)shouldReplaceWordAtRange:(NSRange)range withWord:(NSString *)word;
- (void)shouldHighlightWordInRange:(NSRange)range;

@end


@interface JTTextController : NSObject

@property (nonatomic, assign) id<JTTextControllerDelegate> delegate;

- (void)didChangeSelection;
- (void)didChangeText;

@end
