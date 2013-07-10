//
//  UIView+Clone.h
//
// Created by Jonathon Hibbard on 7/9/13.
// Copyright (c) 2013 Integrated Events, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Clone)
-(id)cloneMainView;
-(id)cloneView:(UIView *)sourceView;
@end