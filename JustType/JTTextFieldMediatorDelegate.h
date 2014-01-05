//
//  JTTextFieldMediatorDelegate.h
//  JustType
//
//  Created by Alexander Koglin on 01.01.14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JTTextField;

/**
 *  This class intercepts the UITextField delegate, such that the textField can react on delegate methods on its own.
 */
@interface JTTextFieldMediatorDelegate : NSObject <UITextFieldDelegate>

/**
 *  The textField that gets notified back on changes.
 */
@property (nonatomic, assign) JTTextField *textField;

@end
