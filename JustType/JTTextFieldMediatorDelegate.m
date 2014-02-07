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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL result = [self.textField textFieldShouldBeginEditing:self.textField];
    if ([self.textField.actualDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        result = [self.textField.actualDelegate textFieldShouldBeginEditing:self.textField];
    }
    return result;
}

// this returns true because we need to forward
// all other calls to the actual delegate
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(textFieldShouldBeginEditing:)) {
        return YES;
    } else {
        return ([self.textField.actualDelegate respondsToSelector:aSelector]);
    }
}

// forward everything else to delegate
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.textField.actualDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.textField.actualDelegate];
    }
}

@end
