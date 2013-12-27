//
//  JTTextView.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTextController.h"

@interface JTTextView : UITextView <JTTextControllerDelegate>

- (id<UITextViewDelegate>)actualDelegate;

- (void)didChangeSelection;
- (void)didChangeText;

@end
