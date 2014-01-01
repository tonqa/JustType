//
//  JTTextFieldMediatorDelegate.m
//  JustType
//
//  Created by Alexander Koglin on 01.01.14.
//
//

#import "JTTextFieldMediatorDelegate.h"
#import "JTTextField.h"

@implementation JTTextFieldMediatorDelegate
@synthesize textField = _textField;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL result = [self.textField textFieldShouldBeginEditing:self.textField];
    if ([self.textField.actualDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        result = [self.textField.actualDelegate textFieldShouldBeginEditing:self.textField];
    }
    return result;
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
