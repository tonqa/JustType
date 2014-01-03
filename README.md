Just Type - The iOS keyboard for everyone
==============


Reasoning
---------------------

**The iOS keyboard and text navigation is often cumbersome**. E.g. in order to jump to the preceding word in a text you need a lot of touches on the top of the text input itself. For going to the next sentence you need to type a dot and a space, of which the former you can not directly reach without using shift (thus 3 touches). Also though there is a built-in syntax checker, you can never directly see what kind of suggestions it does. We can do better!

This project tries to **not change** or temper with the **iOS default behavior** of texts. The highest priority of this project is instead to be fully compatible with iOS UITextFields and UITextViews. The default keyboard and text handling shall not be modified in any imaginable way, but instead this project adds on top of both. 

It **adds own gestures** (via gesture recognizers) to the keyboard, which do not interfere with the existing ones. Also it adds its own way of **syntax highlighting and syntax completion** to iOS default elements (using the UITextInput protocol of UITextView and UITextField). It uses the **default iOS syntax checker**, but changes how the syntax completion is presented. Default syntax completion UI is therefore switched off. 

We want this keyboard **to be used in all apps**, therefore we made it the most user friendly as possible, compatible with all iOS 6 systems and extendable in the most possible way. This is also why it is completely unit-tested.


Advantages
---------------------

* **Performance:** This implementation uses the default UIKit text navigation provided by UITextInput protocol of UITextView and UITextField, which is of course very fast.
* **Compatiblity:** If the default iOS UIKit keyboard handling changes the keyboard gestures extension just stops working. That's why this should not be any critical for apps used in production. In fact we have an app called *'Just Type'* in the App Store.
* **Extendability**: The keyboard and UITextInput extensions are easily extendable for developers (e.g. the behavior for other languages could easily be modified). We in fact encourage you to contribute to this project.


Usage
---------------------
Actually for using this extension there are only three steps. 

1. Add the static library to your project by installing it via pod, dragging the compiled JustType.a in your project or linking the project as a dependency.

2. For attaching the gestures to the keyboard you just need one simple command (e.g. do it in your *application:didFinishLaunching:*):

``
	[[JTKeyboardListener sharedInstance] observeKeyboardGestures:YES];
``

3. For using the input elements out of the box you can use JTTextView exactly like a normal UITextView (or alternatively JTTextField like a UITextField):

``
	JTTextView *textView = [[JTTextView alloc] initWithFrame:self.view.frame];
	[self.view addSubview: textView];
``

Additional options
---------------------

* For using the syntax completion attachment view to the keyboard you need to add the following to your text input element:

``
	JTKeyboardAttachmentView *attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:frame];
	[textView setInputAccessoryView: attachmentView];
``

* If you want to deactivate the visual help (arrows) which occur while swiping then you can switch them off:

``
	[[JTKeyboardListener sharedInstance] setEnableVisualHelp:NO];
``

* Note: You can use the JTTextView and JTTextField also without intercepting gestures by not adding the keyboard listener or turning it off again:

``
	[[JTKeyboardListener sharedInstance] observeKeyboardGestures:YES];
``

* If you want to turn the syntax highlighting off just use the following command on the textView / textField:
``
	textView.isSyntaxHighlightingUsed = NO;
``

* In the case you don't want to support the syntax completion you can also turn it off:
``
	textView.isSyntaxCompletionUsed = NO;
``


As a side note 
---------------------

**Developers unite:** By using this project you will support us to hopefully and finally get Apple improving the default keyboard on their own to support better and faster typing. But for now we have this little extension supporting gestures, syntax highlighting and better syntax completion. 

You will hopefully join us in using this project. We would also be grateful if there is some support from the community filing feature requests, forking, developing and sending pull requests for this project. Thanks for your help and enjoy!