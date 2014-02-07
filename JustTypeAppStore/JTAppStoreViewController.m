//
//  JTAppStoreViewController.m
//  JustTypeAppStore
//
//  Created by Alexander Koglin on 26.01.14.
//
//

#import "JTAppStoreViewController.h"
#import <JustType/JustType.h>

@interface JTAppStoreViewController ()

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

@implementation JTAppStoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // make the text a little bit smaller on iPhone and larger on iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.justTypeTextView setFont:[UIFont systemFontOfSize:20]];
    } else {
        [self.justTypeTextView setFont:[UIFont systemFontOfSize:30]];
    }
    
    // get the frame for the keyboard attachment view (with suggestions),
    // also a little bit larger on the iPad
    CGRect attachmentViewFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        attachmentViewFrame = CGRectMake(0, 0, self.view.frame.size.width, 30.0f);
    } else {
        attachmentViewFrame = CGRectMake(0, 0, self.view.frame.size.width, 40.0f);
    }
    
    self.justTypeTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"text"];

    // this sets up the keyboard attachment view (with suggestions)
    // of the TextView (if available)
    JTKeyboardAttachmentView *textViewAttachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
    [self.justTypeTextView setInputAccessoryView:textViewAttachmentView];
    
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
    
    [[NSUserDefaults standardUserDefaults] setObject:self.justTypeTextView.text forKey:@"text"];

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
    
    // this resizes the view
    CGRect newFrame = self.view.frame;
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
}

@end
