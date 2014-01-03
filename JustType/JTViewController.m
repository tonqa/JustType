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
    [self.textView setFont:[UIFont systemFontOfSize:20]];
    [self.textField setFont:[UIFont systemFontOfSize:20]];

    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, JTViewControllerKeyboardAttachmentViewHeight());
    
    JTKeyboardAttachmentView *textViewAttachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:frame];
    [self.textView setInputAccessoryView:textViewAttachmentView];
    
    JTKeyboardAttachmentView *textFieldAttachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:frame];
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
    //keyboardFrame.size.height += JTViewControllerKeyboardAttachmentViewHeight();

    {
    CGRect newFrame = textView.frame;
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    textView.frame = newFrame;
    }

    {
    CGRect newFrame = textField.frame;
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    textField.frame = newFrame;
    }

    [UIView commitAnimations];
}

@end
