//
//  JTDashedBorderedView.h
//  JustType
//
//  Created by Alexander Koglin on 02.01.14.
//
//

#import <UIKit/UIKit.h>

/**
 *  This is a view used for highlighting the text. It renders its lower border with a dashed line.
 */
@interface JTDashedBorderedView : UIView

/**
 *  The color with which the highlighting of words in textviews is done.
 */
@property (nonatomic, retain) UIColor *strokeColor;

@end
