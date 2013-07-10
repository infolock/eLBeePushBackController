//
//  ModalViewController.h
//  eLBeePushBackController
//
//  Created by Jonathon Hibbard on 7/9/13.
//  Copyright (c) 2013 Integrated Events. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModalViewController;

@protocol ModalVCDelegate <NSObject>
-(void)pushBackVCDelegateShouldDismissController:(ModalViewController *)controller;
@end

@interface ModalViewController : UIViewController
@property (nonatomic, weak) id <ModalVCDelegate> delegate;
@end
