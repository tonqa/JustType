//
//  JTKeyboardOverlayViewDelegate.h
//  JustType
//
//  Created by Alexander Koglin on 08.01.14.
//
//

#import <Foundation/Foundation.h>

@class JTKeyboardOverlayFrameAnimation;
@protocol JTKeyboardOverlayFrameAnimationDelegate <NSObject>

- (void)frameAnimationDidStop:(JTKeyboardOverlayFrameAnimation *)animation;

@end


@interface JTKeyboardOverlayFrameAnimation : NSObject

@property (nonatomic, weak) id<JTKeyboardOverlayFrameAnimationDelegate> delegate;

- (void)startAnimationForView:(UIView *)view arrowDirection:(NSString *)direction;
- (void)startAnimationForView:(UIView *)view fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint ;

@end
