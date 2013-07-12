//
//  MainViewController.m
//  eLBeePushBackController
//
//  Created by Jonathon Hibbard on 7/9/13.
//  Copyright (c) 2013 Integrated Events. All rights reserved.
//

#import "MainViewController.h"
#import "ModalViewController.h"
#import "UIViewController+eLBeePushBackController.h"

@interface MainViewController() <ModalVCDelegate>

@end

@implementation MainViewController

-(IBAction)presentPBVCBtn:(id)sender {
    ModalViewController *controller = (ModalViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewControllerSBID"];
    controller.delegate = self;  // This is not necessary - is good to just let your main view handle presenting/dismissing

    [self presentPushBackController:controller];

    /*
        // Example using withCompletion
        [self presentPushBackController:controller withCompletion:^{
            NSLog(@"The View was pushed and has completed!");
        }];
    */
}

-(void)pushBackVCDelegateShouldDismissController:(ModalViewController *)controller {

    controller.delegate = nil;

    [self dismissPushBackController:controller];
    /*
         // Example using withCompletion
         [self dismissPushBackController:controller withCompletion:^{
         NSLog(@"The View was pushed and has completed!");
         }];
     */
}
@end
