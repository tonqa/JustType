//
//  JTEdgeInsetLabel.h
//  JustType
//
//  Created by Alexander Koglin on 25.01.14.
//
//

#import <UIKit/UIKit.h>

/**
 *  A label that allows to set an inset (which is basically a padding).
 */
@interface JTEdgeInsetLabel : UILabel

/**
 *  The edge inset that can be set
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end
