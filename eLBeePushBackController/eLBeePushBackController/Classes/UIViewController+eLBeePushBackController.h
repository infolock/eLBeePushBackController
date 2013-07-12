//
//  UIViewController+eLBeePushBackController.h
//  eLBee
//
//  Created by Jonathon Hibbard on 7/9/13.
//  Copyright (c) 2013 Integrated Events, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^eLBeePBCompletionBlock)(void);


@interface UIViewController(eLBeePushBackController)

typedef NS_ENUM(NSInteger, keLBeePBVCSize) {
    keLBeeSizePresentedViewHeight = 328
};

typedef NS_ENUM(NSInteger, keLBeePBVCTag) {
    keLBeePBVCTagOverlay = 10001,
    keLBeePBVCTagRootView = 10002,
    keLBeePBVCTagPresentedView = 10003
};

-(void)presentPushBackController:(UIViewController *)controller;
-(void)presentPushBackController:(UIViewController *)controller withCompletion:(eLBeePBCompletionBlock)completion;

-(void)dismissPushBackController:(UIViewController *)controller;
-(void)dismissPushBackController:(UIViewController *)controller withCompletion:(eLBeePBCompletionBlock)completion;
@end
