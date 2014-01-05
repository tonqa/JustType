Just Type - The iOS keyboard for everyone
==============

[![Version](http://cocoapod-badges.herokuapp.com/v/JustType/badge.png)](http://cocoadocs.org/docsets/JustType)
[![Platform](http://cocoapod-badges.herokuapp.com/p/JustType/badge.png)](http://cocoadocs.org/docsets/JustType)

![Editing text field using suggestions](http://dl.dropboxusercontent.com/u/82016/justtype_1_small.png)
![Editing text view using gestures](http://dl.dropboxusercontent.com/u/82016/justtype_2_small.png)

Reasoning
---------------------

**The iOS keyboard and text navigation is often cumbersome**. E.g. in order to jump to the preceding word in a text you need a lot of touches on the top of the text input itself. For going to the next sentence you need to type a dot and a space, of which the former you can not directly reach without using shift (thus 3 touches). Also though there is a built-in syntax checker, you can never directly see what words it suggests. We can do better!

This project tries to **not change** or temper with the **iOS default behavior** of texts. The highest priority of this project is instead to be fully compatible with iOS UITextFields and UITextViews. The default keyboard and text handling shall not be modified in any imaginable way, but instead this project adds on top of both. 

It **adds own gestures** (via gesture recognizers) to the keyboard, which do not interfere with the existing ones. Also it adds its own way of **syntax highlighting and syntax completion** to iOS default elements (using the UITextInput protocol of UITextView and UITextField). It uses the **default iOS syntax checker**, but changes how the syntax completion is presented. Default syntax completion UI is therefore switched off. 

We want this keyboard **to be used in all apps**, therefore we made it the most user friendly as possible, compatible with all iOS 6 systems and extendable in the most possible way. This is also why it is completely unit-tested.

Advantages
---------------------

* **Performance:** This implementation uses the default UIKit text navigation provided by UITextInput protocol of UITextView and UITextField, which is of course very fast.
* **Compatiblity:** This framework is compatible with iOS 6 and 7. It builds on the default UIKit. If the keyboard handling in later iOS versions changes the keyboard gestures extension just stops working. That's why this should not be any critical for apps used in production. In fact we have a demo app called *'Just Type'* in the App Store ourselves.
* **Extendability**: The keyboard and UITextInput extensions are easily extendable for developers (e.g. the behavior for other languages could easily be modified). We in fact encourage you to contribute to this project.


Usage
---------------------
Actually for using this keyboard extension there are only three steps to follow. 

1. Add the static library to your project by either dragging the already compiled *libJustType.a* in your project or linking the JustType project sources as a project dependency or installing it via [CocoaPods](http://www.cocoapods.org) (see below).

        $ cd <Your Project>  # go to your project
        $ vim Podfile        # create Podfile (and save)
          > platform :ios
          > pod 'JustType'
        $ pod install        # install libraries from Podfile

1. You should check that the import works by adding to your *AppDelegate.m*:

        #import <JustType/JustType.h>

1. For attaching the gestures to the keyboard you just need one simple command (e.g. do it in your *application:didFinishLaunching:*):

        [[JTKeyboardListener sharedInstance] observeKeyboardGestures:YES];

1. For using the text input elements you can use *JTTextView* exactly like a normal *UITextView* (or alternatively *JTTextField* like a *UITextField*) out of the box:

        JTTextView *textView = [[JTTextView alloc] initWithFrame:self.view.frame];
        [self.view addSubview: textView];

Hint: Under *"Workspace / Target / Build Settings"* you should check that the option *"all other linker flags"* is set to *"-all_load -ObjC"*, otherwise the compiler won't find the library classes e.g. when using lazy loading in nib files.

Additional options
---------------------

* For using the syntax completion attachment view for the keyboard you need to add the following to your textView or textField:

        CGRect attachmentViewFrame = CGRectMake(0, 0, self.view.size.width, <height>);
        JTKeyboardAttachmentView *attachmentView = [[JTKeyboardAttachmentView alloc] 
                                      initWithFrame: attachmentViewFrame];
        [textView setInputAccessoryView: attachmentView];

* You can add your own highlighting style to a textView by creating and own UIView for highlighting, overwriting its *drawRect:* method and adding this highlightView to the textView (only on textViews):

        UIView *myOwnHighlightView = [[MyOwnHighlightingView alloc] 
                                         initWithFrame:CGRectZero];
        textView.highlightView = myOwnHighlightView;

* To adapt the style of textFields instead there are two textColor properties, of which the unhighlightedColor is black for default and the highlightedColor is gray by default (only textFields):

        textField.backgroundColor = [UIColor blackColor];
        textField.unhighlightedColor = [UIColor whiteColor];
        textField.highlightedColor = [UIColor lightGrayColor];

* If you want to create an own view for displaying the suggestions you can set a delegate corresponding to the *JTTextSuggestionDelegate* protocol and implement some of the optional protocol methods:

        textView.textSuggestionDelegate = self;

* When you implement this protocol it will be useful to replace suggestions for the current word by calling the following method on the textView / textField:

        [textView selectSuggestionByIndex: suggestionIndex];

* If you want to turn the syntax highlighting off just use the following command on the textView / textField:

        textView.isSyntaxHighlightingUsed = NO;

* In the case you don't want to support the syntax completion you can also turn it off for the textView / textField:

        textView.isSyntaxCompletionUsed = NO;

* If you want to deactivate the visual help (arrows) which occur on top of the keyboard while swiping then you can switch them off, too:

        [[JTKeyboardListener sharedInstance] setEnableVisualHelp:NO];

* Note: You can use the *JTTextView* and *JTTextField* also stand-alone for syntax highlighting and completion  without intercepting gestures on the keyboard. You can do this by simply not adding the keyboard listener (from step 3) at all or turning it off again after you turned it on:

        [[JTKeyboardListener sharedInstance] observeKeyboardGestures:NO];


As a side note 
---------------------

**Developers unite:** By using this project you will support us to hopefully and finally get Apple improving the default keyboard on their own to support better and faster typing. But for now we have this little extension supporting gestures, syntax highlighting and better syntax completion. 

You will hopefully join us in using this project. We would also be grateful if there is some support from the community filing feature requests, forking, developing and sending pull requests for this project. Thanks for your help and enjoy!

Creative Commons License
--------------------
        JustType by Alexander Koglin
        
        To the extent possible under law, the person who associated CC0 with
        JustType has waived all copyright and related or neighboring rights
        to JustType.

        You should have received a copy of the CC0 legalcode along with this
        work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.