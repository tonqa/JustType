
The Better Keyboard for iOS
---------------------

[![License](https://dl.dropboxusercontent.com/u/82016/cc.png)](https://github.com/tonqa/JustType/blob/master/LICENSE)
[![Github](https://dl.dropboxusercontent.com/u/82016/GitHub_Logo.png)](https://github.com/tonqa/justtype)
[![Platform](http://cocoapod-badges.herokuapp.com/p/JustType/badge.png)](http://cocoadocs.org/docsets/JustType)
[![Version](http://cocoapod-badges.herokuapp.com/v/JustType/badge.png)](http://cocoadocs.org/docsets/JustType)
[![Build Status](https://travis-ci.org/tonqa/JustType.png?branch=master)](https://travis-ci.org/tonqa/JustType)

JustType is a keyboard extension using swipe gestures, highlighting and suggestions. It is built to be used in any iOS text editor and all text-intensive iOS apps. And it is really easy to use. If you want to have a video demonstration you can [find it on this blogpost](http://www.eglador.de/files/4e4f3394e0c39424ff87953dce60d031-23.php "Demo").

[![Editing text field using suggestions](http://dl.dropboxusercontent.com/u/82016/justtype_1_small.png)](http://dl.dropboxusercontent.com/u/82016/justtype_1.png) &nbsp;&nbsp; [![Editing text view using gestures](http://dl.dropboxusercontent.com/u/82016/justtype_2_small.png)](http://dl.dropboxusercontent.com/u/82016/justtype_2.png)


### Features

JustType **adds own gestures** to the keyboard, which do not interfere with the default keyboard. It allows to **smart jump** between words of texts by swiping left and right on the keyboard. It adds **highlighting** and **suggestions** for currently selected words to iOS default text inputs. It does that by using the **default iOS syntax checker**.

### Reasoning

Recently, there has been quite a lot **buzz around keyboards** for iOS. We liked the [Fleksy keyboard](http://fleksy.com/) as well as [some other prototypes](http://www.youtube.com/watch?v=RGQTaHGQ04Q) a lot and also we are fans of the [Swype keyboard](http://www.swype.com/), which can be easily installed on every Android smartphone on the market. The [SwiftKey](http://www.swiftkey.net/en/) app brought intelligent predictions to the iOS device recently and [HipJot](http://jormy.com/hipjot/) also had a quite compelling user interface, but required a high learning curve.

These all were amazing projects, but there is a lack of keyboard extensions for the **native iOS UI**, which are **freely available** for every app developer. We want something to be more built-in. So we built a framework on top of the existing UIKit of iOS, which integrates much better with the traditional text input.

**The iOS keyboard and text navigation is often cumbersome**. E.g. in order to jump to the preceding word in a text you need a lot of touches on the top of the text input itself. You can not directly make the word upper or lower case if you are in between a word. Also though there is a built-in syntax checker, you can only choose a suggestion by holding on a word. You never directly see what words it suggests. We can do better!

This project tries to **not change** or temper with the **iOS default behavior** of texts. The highest priority of this project is instead to be fully compatible with iOS UITextFields and UITextViews. The default keyboard and text handling shall not be modified in any imaginable way, but instead this project adds on top of both. 

We want this extension **to be usable in all apps**, therefore we made it the most user friendly as possible, compatible with all iOS 6 systems and extendable in the most possible way. This is also why it is completely unit-tested.

### Advantages

* **Broad language support**: Practically every language is supported, because no keyboard functionality is replaced. All languages which work in iOS also work with JustType.
* **No enforcement**: Beginners do not need to use the gestures if they don't want to. Instead they can work exactly like they know it from any of their iOS apps.
* **Performance:** This implementation uses the default UIKit text navigation provided by UITextInput protocol of UITextView and UITextField, which is of course very fast. Also it uses iOS gesture recognizers for gestures on the keyboard.
* **Compatiblity:** This framework is compatible with iOS 6 and 7. It builds on the default UIKit. If the keyboard handling in later iOS versions changes the keyboard gestures extension just stops working. That's why this should not be any critical for apps used in production. In fact we have a demo app called *'Just Type'* in the App Store ourselves.
* **Extendability**: The keyboard and UITextInput extensions are easily extendable for developers (e.g. the behavior for gestures could easily be modified). We in fact encourage you to contribute to this project.


### Usage

Actually for using this keyboard extension there are only four steps to follow. 

1. Add the framework to your project by either linking the JustType project sources [as a project dependency](http://www.cocoanetics.com/2011/12/sub-projects-in-xcode/), [dragging headers and libJustType.a in your project](http://www.raywenderlich.com/41377/creating-a-static-library-in-ios-tutorial), or installing it via [CocoaPods](http://www.cocoapods.org) (see below).

	<pre>
        $ <b><font color="#008080">cd &lt;Your Project&gt;</font></b>  # go to your project
        $ <b><font color="#008080">vim Podfile</font></b>        # create Podfile (and save)
          > platform :ios
          > pod 'JustType'
        $ <b><font color="#008080">pod install</font></b>        # install libraries from Podfile
	</pre>

2. You should check that the import works by adding to your *AppDelegate.m*:

	<pre>
        #import &lt;<b><font color="#008080">JustType/JustType.h</font></b>&gt;
	</pre>

3. For attaching the gestures to the keyboard you just need one simple command (e.g. do it in your *application:didFinishLaunching:*):

	<pre>
        [[<b><font color="#008080">JTKeyboardListener</font></b> sharedInstance] observeKeyboardGestures:YES];
	</pre>

4. For using the text input elements you can use *JTTextView* exactly like a normal *UITextView* (or alternatively *JTTextField* like a *UITextField*) out of the box:

	<pre>
        <b><font color="#008080">JTTextView</font></b> *textView = [[<b><font color="#008080">JTTextView</font></b> alloc] initWithFrame:self.view.frame];
        [self.view addSubview:textView];
	</pre>

<sub><b>Hint:</b> Under *"Workspace / Target / Build Settings"* you should check that the option *"all other linker flags"* is set to *"-all_load -ObjC"*, otherwise the compiler won't find the library classes e.g. when using lazy loading in nib files. If you have a project not including ARC then also set the linker option *"-fobjc-arc"*.</sub>

### Additional options

For **adding the attachment view** that presents suggestions for the current word *(recommended)* you need to add the following to your textView or textField.

```objc
CGRect attachmentViewFrame = CGRectMake(0, 0, self.view.size.width, <height>);
JTKeyboardAttachmentView *attachmentView = [[JTKeyboardAttachmentView alloc] 
                          initWithFrame:attachmentViewFrame];
[textView setInputAccessoryView:attachmentView];
```

You can **add your own highlighting style** to a textView by creating an own UIView for highlighting, overwriting its *drawRect:* method and adding this highlightView to the textView *(only on textViews)*:

```objc
UIView *myOwnHighlightView = [[MyOwnHighlightingView alloc] initWithFrame:CGRectZero];
textView.highlightView = myOwnHighlightView;
```

Instead you can also simply **adapt the color used** for the default highlighting view displaying underdashes below the selected word. As the default it uses the window tintColor *(only on textViews)*:

```objc
UIView *highlightView = textView.highlightView;
[(JTDashedBorderedView *)highlightView setStrokeColor:[UIColor blackColor]];
```

To **adapt the style of textFields** instead there are two textColor properties, of which the unhighlightedColor is black for default and the highlightedColor is gray by default *(only textFields)*:

```objc
textField.backgroundColor = [UIColor blackColor];
textField.unhighlightedColor = [UIColor whiteColor];
textField.highlightedColor = [UIColor lightGrayColor];
```

If you want to **create an own view for displaying the suggestions** you can set a delegate corresponding to the *JTTextSuggestionDelegate* protocol and implement some of the optional protocol methods:

```objc
textView.textSuggestionDelegate = self;
```

If you want to implement this suggestion delegate protocol it will be useful to **replace suggestions for the current word** by calling the following method on the textView / textField:

```objc
[textView selectSuggestionByIndex:suggestionIndex];
```

If you want to **turn the word highlighting off** just use the following command on the textView / textField:

```objc
textView.isSyntaxHighlightingUsed = NO;
```

In the case you don't want to support **the syntax completion** you can also **turn it off** for the textView / textField:

```objc
textView.isSyntaxCompletionUsed = NO;
```

You can also **adapt the colors used for the gestures** on the keyboard by using these properties. As a default they are set to the window tintColor and its complementary color.

```objc
[[JTKeyboardListener sharedInstance] setTouchDownColor:[UIColor redColor]];
[[JTKeyboardListener sharedInstance] setTouchMoveColor:[UIColor redColor]];
```

If you want to **deactivate the visual help** for gestures which occur on top of the keyboard while swiping then you can switch them off, too:

```objc
[[JTKeyboardListener sharedInstance] setEnableVisualHelp:NO];
```

**Note:** You can use the *JTTextView* and *JTTextField* also stand-alone for word highlighting and completion without using gestures on the keyboard. You can do this by simply not adding the keyboard listener (from step 3) at all or turning it off again after you turned it on:

```objc
[[JTKeyboardListener sharedInstance] observeKeyboardGestures:NO];
```

### As a side note 

**Developers unite:** By using this project you will support us to hopefully and finally get Apple improving the default keyboard on their own to support better and faster typing. But for now we have this little extension supporting gestures, syntax highlighting and better syntax completion. 

You will hopefully join us in using this project. We would also be grateful if there is some support from the community filing feature requests, forking, developing and sending pull requests for this project. Thanks for your help and enjoy!

### Creative Commons License

JustType is under the CC0 license, which means that all copyrights have been waived. So enjoy!

        JustType by Alexander Koglin
        
        To the extent possible under law, the person who associated CC0 with
        JustType has waived all copyright and related or neighboring rights
        to JustType.

        You should have received a copy of the CC0 legalcode along with this
        work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.