//
//  JTTextView+TestsPrivate.h
//  JustType
//
//  Created by Alexander Koglin on 06.01.14.
//
//

#import <JustType/JustType.h>

@class JTTextViewMediatorDelegate;
@interface JTTextView (TestsPrivate)

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, assign) id<UITextViewDelegate> actualDelegate;
@property (nonatomic, retain) JTTextViewMediatorDelegate *mediatorDelegate;

- (void)setupView;

@end
