//
//  JTViewController.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTViewController.h"
#import "JTTextView.h"
#import "JTTextField.h"

#define JTViewControllerKeyboardAttachmentViewHeight() 30.0f

@interface JTViewController ()

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end


@implementation JTViewController
@synthesize textField;
@synthesize textView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // make the text a little bit smaller on iPhone and larger on iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.textView setFont:[UIFont systemFontOfSize:20]];
        [self.textField setFont:[UIFont systemFontOfSize:20]];
    } else {
        [self.textView setFont:[UIFont systemFontOfSize:30]];
        [self.textField setFont:[UIFont systemFontOfSize:30]];
    }

    // get the frame for the keyboard attachment view (with suggestions)
    CGRect attachmentViewFrame = CGRectMake(0, 0, self.view.frame.size.width, JTViewControllerKeyboardAttachmentViewHeight());
    
    // this sets up the keyboard attachment view (with suggestions)
    // of the TextView (if available)
    JTKeyboardAttachmentView *textViewAttachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
    [self.textView setInputAccessoryView:textViewAttachmentView];
    
    // this sets up the keyboard attachment view (with suggestions)
    // of the TextField (if available)
    JTKeyboardAttachmentView *textFieldAttachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
    [self.textField setInputAccessoryView:textFieldAttachmentView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // this is the typical Apple way to listen for keyboard notification in order to resize the TextInput element when keyboard comes up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
}

/**
 * This method resizes the TextInputView (TextField or TextView). 
 * If the keyboard comes up the TextInputView shrinks to be smaller. 
 * If the keyboard goes down the TextInputView is made larger again.
 */
- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];

    // this resizes the TextView (if available)
    {
        CGRect newFrame = textView.frame;
        newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
        textView.frame = newFrame;
    }

    // this resizes the TextField (if available)
    {
        CGRect newFrame = textField.frame;
        newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
        textField.frame = newFrame;
    }

    [UIView commitAnimations];
}

@end
