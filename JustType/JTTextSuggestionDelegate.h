//
//  JTTextSuggestionDelegate.h
//  JustType
//
//  Created by Alexander Koglin on 03.01.14.
//
//

#import <Foundation/Foundation.h>

@protocol JTTextSuggestionDelegate <NSObject>

@optional
- (void)didSelectWord:(NSString *)word
              atRange:(NSRange)range
          suggestions:(NSArray *)suggestions;

- (void)didSelectSuggestionIndex:(NSInteger)selectedIndex;

- (void)didClearSelection;

@end
