//
//  JTTextFieldMediatorDelegate.h
//  JustType
//
//  Created by Alexander Koglin on 01.01.14.
//
//

#import <Foundation/Foundation.h>

@class JTTextField;
@interface JTTextFieldMediatorDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, assign) JTTextField *textField;

@end
