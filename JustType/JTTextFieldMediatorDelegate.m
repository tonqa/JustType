//
//  JTTextFieldMediatorDelegate.m
//  JustType
//
//  Created by Alexander Koglin on 01.01.14.
//
//

#import "JTTextFieldMediatorDelegate.h"
#import "JTTextField.h"

@interface JTTextField (JTTextFieldMediatorDelegate)

- (id<UITextFieldDelegate>)actualDelegate;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

@end


@implementation JTTextFieldMediatorDelegate
@synthesize textField = _textField;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.textField.actualDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.textField.actualDelegate textFieldDidBeginEditing:self.textField];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL result = [self.textField textFieldShouldBeginEditing:self.textField];
    if ([self.textField.actualDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        result = [self.textField.actualDelegate textFieldShouldBeginEditing:self.textField];
    }
    return result;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL result = YES;
    if ([self.textField.actualDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        result = [self.textField.actualDelegate textFieldShouldEndEditing:self.textField];
    }
    return result;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.textField.actualDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.textField.actualDelegate textFieldDidEndEditing:self.textField];
    }
}

// forward everything else to delegate
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.textField.actualDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.textField.actualDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
