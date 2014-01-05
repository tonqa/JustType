//
//  JTTextViewMediatorDelegate.h
//  JustType
//
//  Created by Alexander Koglin on 27.12.13.
//  Copyright (c) 2013 Alexander Koglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JTTextView;

/**
 *  This class intercepts the UITextView delegate, such that the textView can react on delegate methods on its own.
 */
@interface JTTextViewMediatorDelegate : NSObject<UITextViewDelegate>

/**
 *  The textView that gets notified back on changes
 */
@property (nonatomic, assign) JTTextView *textView;

@end
