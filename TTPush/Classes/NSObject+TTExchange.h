//
//  NSObject+TTExchange.h
//  Pods-TTPush_Example
//
//  Created by yxt on 2018/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TTExchange)

void tt_swizzleMethodImplementation(Class originC,Class cusC ,SEL originSEL, SEL cusSEL);

@end

NS_ASSUME_NONNULL_END
