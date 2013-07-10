//
// UIView+Clone.m
//
// Created by Jonathon Hibbard on 7/9/13.
// Copyright (c) 2013 Integrated Events, LLC. All rights reserved.
//

#import "UIView+Clone.h"
@implementation UIView(Clone)

-(id)cloneMainView {
    UIView *__weak view = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    return view;
}

-(id)cloneView:(UIView *)sourceView {
    UIView *__weak view = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:sourceView]];
    return view;
}
@end