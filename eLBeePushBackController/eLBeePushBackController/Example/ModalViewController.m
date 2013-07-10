//
//  ModalViewController.m
//  eLBeePushBackController
//
//  Created by Jonathon Hibbard on 7/9/13.
//  Copyright (c) 2013 Integrated Events. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController()

-(IBAction)dismissAction;

@end


@implementation ModalViewController

-(IBAction)dismissAction {
    [self.delegate pushBackVCDelegateShouldDismissController:self];
}

@end
