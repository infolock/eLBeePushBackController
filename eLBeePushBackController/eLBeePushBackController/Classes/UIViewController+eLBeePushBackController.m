//
//  UIViewController+eLBeePushBackController.m
//  eLBee
//
//  Created by Jonathon Hibbard on 7/9/13.
//  Copyright (c) 2013 Integrated Events, LLC. All rights reserved.
//

#import "UIViewController+eLBeePushBackController.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (eLBeePushBackController)

#pragma mark -
#pragma mark Public Methods
#pragma mark -

#pragma mark presentPushBack

-(void)presentPushBackController:(UIViewController *)controller {
    [self presentPushBackController:controller withCompletion:nil];
}

// Performs the actual presentation transition
-(void)presentPushBackController:(UIViewController *)controller withCompletion:(eLBeePBCompletionBlock)completion {

    UIViewController *targetVC = self.parentViewController;
    [targetVC addChildViewController:controller];

    self.view.tag = keLBeePBVCTagRootView;
    self.view.autoresizesSubviews = YES;
    self.view.userInteractionEnabled = NO;

    [controller beginAppearanceTransition:YES animated:YES];
    [self transitionToModalView:controller.view withCompletion:^{
        [controller didMoveToParentViewController:targetVC];
        [controller endAppearanceTransition];
        if(completion) {
            completion();
        }
    }];
}

#pragma mark dismissPushBack

-(void)dismissPushBackController:(UIViewController *)controller {
    [self dismissPushBackController:controller withCompletion:nil];
}

// Performs the dismiss transition
-(void)dismissPushBackController:(UIViewController *)controller withCompletion:(eLBeePBCompletionBlock)completion {

    UIView *target = self.parentViewController.view;
    UIView *__weak modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView *__weak overlay = [target.subviews objectAtIndex:target.subviews.count-2];

    self.view.userInteractionEnabled = YES;

    [controller willMoveToParentViewController:nil];
    [controller beginAppearanceTransition:NO animated:YES];


    [self restoreViewWithCompletion:completion];

    CGRect modalFrame = modal.frame;
    modalFrame.origin = CGPointMake(0, target.bounds.size.height);

    [UIView animateWithDuration:0.4 animations:^{
        modal.frame = modalFrame;
    } completion:^(BOOL finished) {

        [overlay removeFromSuperview];
        [modal removeFromSuperview];

        [controller removeFromParentViewController];
        if([controller respondsToSelector:@selector(endAppearanceTransition)]) {
            [controller endAppearanceTransition];
        }

        if(completion) {
            completion();
        }
    }];

}

#pragma mark -
#pragma mark Private Methods
#pragma mark -

// Controls pushing the root view back
-(void)transitionToModalView:(UIView *)modalView withCompletion:(eLBeePBCompletionBlock)completion {

    UIView *target = self.parentViewController.view;

    if(![target.subviews containsObject:modalView]) {

        CGFloat yPos = self.view.frame.size.height - keLBeeSizePresentedViewHeight;
        CGFloat pushBackViewHeight = modalView.frame.size.height;
        CGRect modelViewFrame = CGRectMake(0, yPos, target.bounds.size.width, pushBackViewHeight);

        modalView.frame = CGRectOffset(modelViewFrame, 0, +pushBackViewHeight);
        modalView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        modalView.tag = keLBeePBVCTagPresentedView;

        [self addOverlayToTarget:target];
        [target addSubview:modalView];

        UIView *__weak currentView = self.view;
        __block CALayer *viewLayer = currentView.layer;
        [self animateViewUsingTransform3DIdentity:YES usingBlock:^(CAAnimation *caAnimation) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [viewLayer addAnimation:caAnimation forKey:@"pushedBackAnimation"];

                [UIView animateWithDuration:0.4 animations:^{
                    modalView.frame = modelViewFrame;
                } completion:^(BOOL finished) {
                    if(finished && completion) {
                        completion();
                    }
                }];
            });
        }];
    }
}

-(void)addOverlayToTarget:(UIView *)target {

    UIView *overlay = [[UIView alloc] initWithFrame:target.bounds];
    overlay.userInteractionEnabled = NO;
    overlay.backgroundColor = [UIColor blackColor];
    overlay.tag = keLBeePBVCTagOverlay;
    overlay.alpha = 0.5;
    overlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;

    [target addSubview:overlay];
}


#pragma mark -
#pragma mark Animation Methods
#pragma mark -


// This method is called to restore the root view controller where it belongs, and removes the cloned view from our site.
-(void)restoreViewWithCompletion:(eLBeePBCompletionBlock)completion {

    UIView *__weak view = self.view;
    __block CALayer *layer = self.view.layer;
    [self animateViewUsingTransform3DIdentity:NO usingBlock:^(CAAnimation *caAnimation) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [layer addAnimation:caAnimation forKey:@"bringForwardAnimation"];
            [UIView animateWithDuration:0.4 animations:^{
                view.alpha = 1;
            } completion:^(BOOL finished) {

                if(finished && completion) {
                    self.view.autoresizesSubviews = NO;
                    completion();
                }
            }];
        });
    }];
}

#pragma mark -
#pragma mark Transform Animation Methods
#pragma mark -

// Determines how we will be manipulating the cloned root view and what sort of transition we'll be performing
-(void)animateViewUsingTransform3DIdentity:(BOOL)transform3DIdentity usingBlock:(void(^)(CAAnimation *caAnimation))block {

    __block CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    __block CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    __block CAAnimationGroup *group = [CAAnimationGroup animation];

    CGFloat parentViewControllerHeight = self.parentViewController.view.frame.size.height;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        CFTimeInterval duration = 0.4;

        CATransform3D t1 = CATransform3DIdentity;
        t1.m34 = 1.0/-900;
        t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
        t1 = CATransform3DRotate(t1, (CGFloat) (15.0f*M_PI/180.0f), 1, 0, 0);
        animation.toValue = [NSValue valueWithCATransform3D:t1];
        animation.duration = duration/2;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

        CATransform3D t2 = CATransform3DIdentity;
        t2.m34 = t1.m34;
        t2 = CATransform3DTranslate(t2, 0, parentViewControllerHeight*-0.05, 0);
        t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
        animation2.toValue = [NSValue valueWithCATransform3D:(transform3DIdentity ? t2 : CATransform3DIdentity)];
        animation2.beginTime = animation.duration;
        animation2.duration = animation.duration;
        animation2.fillMode = kCAFillModeForwards;
        animation2.removedOnCompletion = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            group.fillMode = kCAFillModeForwards;
            group.removedOnCompletion = NO;
            [group setDuration:animation.duration*2];
            [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];

            if(block) {
                block(group);
            }
        });
    });
}

@end
