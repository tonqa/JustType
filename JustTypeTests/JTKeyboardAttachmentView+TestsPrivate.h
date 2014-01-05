//
//  JTKeyboardAttachmentView+TestsPrivate.h
//  JustType
//
//  Created by Alexander Koglin on 06.01.14.
//
//

#import <JustType/JustType.h>

@interface JTKeyboardAttachmentView (TestsPrivate)

@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, assign) CGFloat fontSize;

- (void)setDisplayedWords:(NSArray *)displayedWords;
- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font;

@end
