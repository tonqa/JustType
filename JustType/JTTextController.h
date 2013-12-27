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

- (void)highlightWord:(BOOL)shouldBeHighlighted inRange:(NSRange)range;

//- (void)shouldReplaceWordAtRange:(NSRange)range withWord:(NSString *)word;    => replaceRange:
//- (void)shouldSelectTextInRange:(NSRange)range;                               => setSelectedTextRange:

@end


@interface JTTextController : NSObject

@property (nonatomic, assign) id<JTTextControllerDelegate, UITextInput> delegate;

- (void)didChangeSelection;
- (void)didChangeText;

@end
