//
//  JTTextViewMediatorDelegate.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JTTextView;

@interface JTTextViewMediatorDelegate : NSObject<UITextViewDelegate>

@property (nonatomic, assign) JTTextView *textView;

@end
