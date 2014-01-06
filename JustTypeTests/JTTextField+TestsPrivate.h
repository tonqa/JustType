//
//  JTTextField+TestsPrivate.h
//  JustType
//
//  Created by Alexander Koglin on 06.01.14.
//
//

#import <JustType/JustType.h>

@class JTTextFieldMediatorDelegate;
@interface JTTextField (TestsPrivate)

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *pressGesture;
@property (nonatomic, assign) id<UITextFieldDelegate> actualDelegate;
@property (nonatomic, retain) JTTextFieldMediatorDelegate *mediatorDelegate;

@end
