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

@interface JTTextViewMediatorDelegate : NSObject<UITextViewDelegate>

@property (nonatomic, assign) JTTextView *textView;

@end
