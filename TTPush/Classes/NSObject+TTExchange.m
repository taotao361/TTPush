//
//  NSObject+TTExchange.m
//  Pods-TTPush_Example
//
//  Created by yxt on 2018/12/26.
//

#import "NSObject+TTExchange.h"
#import <objc/runtime.h>

@implementation NSObject (TTExchange)

void tt_swizzleMethodImplementation(Class originC,Class cusC ,SEL originSEL, SEL cusSEL) {
    Method originMethod = class_getInstanceMethod(originC, originSEL);
    Method cusMethod = class_getInstanceMethod(cusC, cusSEL);
    if (!originMethod) {
        BOOL added = class_addMethod(originC, cusSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (added) {
            class_replaceMethod(originC, originSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        }
    } else {
        method_exchangeImplementations(originMethod, cusMethod);
    }
}

@end
