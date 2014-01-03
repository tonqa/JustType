//
//  JTViewController.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTTextField;
@class JTTextView;
@interface JTViewController : UIViewController

@property (weak, nonatomic) IBOutlet JTTextField *justTypeTextField;
@property (weak, nonatomic) IBOutlet JTTextView *justTypeTextView;

@property (weak, nonatomic) IBOutlet UITextField *defaultTextField;
@property (weak, nonatomic) IBOutlet UITextView *defaultTextView;

@end
