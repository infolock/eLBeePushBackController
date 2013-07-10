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
    UIViewController *targetParentVC = self.parentViewController;
    [targetParentVC addChildViewController:controller];

    [controller beginAppearanceTransition:YES animated:YES];

    [self showPushBackView:controller.view completion:^{

        [controller didMoveToParentViewController:targetParentVC];
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
    UIView *modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView *overlay = [target.subviews objectAtIndex:target.subviews.count-2];

    [controller willMoveToParentViewController:nil];
    [controller beginAppearanceTransition:NO animated:YES];

    [self animateAndRemovePushBackViewController:controller target:target modal:modal overlay:overlay];
    [self restoreClonedView:(UIView *)[overlay.subviews objectAtIndex:0] withCompletion:completion];
}

#pragma mark -
#pragma mark Private Methods
#pragma mark -

// Controls pushing the root view back
-(void)showPushBackView:(UIView *)PushBackView completion:(void (^)(void))completionCallback {

    UIView *target = self.parentViewController.view;
    if(![target.subviews containsObject:PushBackView]) {
        __block UIView * overlay = [[UIView alloc] initWithFrame:target.bounds];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setupOverlay:overlay];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performPushBackWithView:PushBackView completionCallback:completionCallback target:target overlay:overlay];
            });
        });
    }
}


// Sets the necessary properties of the root view to ensure it can resize properly
-(void)setupModalView:(UIView *)PushBackView withFrame:(CGRect)PushBackViewFrame {

    CGFloat PushBackViewHeight = PushBackView.frame.size.height;

    PushBackView.frame = CGRectOffset(PushBackViewFrame, 0, +PushBackViewHeight);
    PushBackView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    PushBackView.tag = keLBeePBVCTagPresentedView;
}

// Creates a "clone" of the root view, which is what will actually be manipulated in the setupModalView so that we don't mess anything up
-(void)getCloneViewForContainer:(UIView *)containerView usingBlock:(void(^)(UIView *clonedView))block {
    __block UIView *currentView = [self.view cloneMainView];
    CGSize currentViewSize = self.view.frame.size;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect currentViewFrame= [self getFrameForCurrentView:currentView currentViewSize:currentViewSize];
        currentView.frame = currentViewFrame;
        dispatch_async(dispatch_get_main_queue(), ^{
            [containerView addSubview:currentView];
            if(block) {
                block(currentView);
            }
        });
    });
}

// Obtains the current view's frame and properties
-(CGRect)getFrameForCurrentView:(UIView *)currentView currentViewSize:(CGSize)currentViewSize {
    CGFloat sizeOffset = keLBeePBVCSizeOffset;
    CGFloat positionOffset = sizeOffset/2;

    CGFloat newWidth = currentViewSize.width - sizeOffset;
    CGFloat newHeight = currentViewSize.height - sizeOffset;

    currentView.tag = keLBeePBVCTagRootView;
    currentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    CGRect currentViewFrame = CGRectMake(positionOffset, positionOffset, newWidth, newHeight);
    return currentViewFrame;
}

// Applies some makeup to the overlay
-(void)setupOverlay:(UIView *)overlay {
    overlay.backgroundColor = [UIColor blackColor];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlay.tag = keLBeePBVCTagOverlay;
}

// This is the "foot in the door" method that starts the actual animation chain.
-(void)performPushBackWithView:(UIView *)PushBackView completionCallback:(void (^)())completionCallback target:(UIView *)target overlay:(UIView *)overlay {
    CGRect PushBackViewFrame = [self getPushBackViewFrameWithHeight:PushBackView.frame.size.height usingTargetBounds:target.bounds];
    [self setupModalView:PushBackView withFrame:PushBackViewFrame];
    [self animateClonedView:PushBackView
         completionCallback:completionCallback
                     target:target
                    overlay:overlay
          PushBackViewFrame:PushBackViewFrame];
}

// Obtains the frame for the view we'll be pushing back
-(CGRect)getPushBackViewFrameWithHeight:(CGFloat)PushBackViewHeight usingTargetBounds:(CGRect)targetBounds {
    CGFloat yPos = self.view.frame.size.height - keLBeePBVCSizeOfPresentedView;
    return CGRectMake(0, yPos, targetBounds.size.width, PushBackViewHeight);
}

#pragma mark -
#pragma mark Animation Methods
#pragma mark -

// Animates the "cloned" root view by applying an overlay on top of it, and then calling the animatePushBackView method
-(void)animateClonedView:(UIView *)PushBackView completionCallback:(void (^)(void))completionCallback target:(UIView *)target overlay:(UIView *)overlay PushBackViewFrame:(CGRect)PushBackViewFrame {

    [self getCloneViewForContainer:overlay usingBlock:^(UIView *cloneView) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [target addSubview:overlay];
            [self animatePushBackView:PushBackView
                    completionCallback:completionCallback
                                target:target
                         PushBackViewFrame:PushBackViewFrame
                              duration:0.4
                             cloneView:cloneView];
        });
    }];
}

// Handles pushing the view back
-(void)animatePushBackView:(UIView *)PushBackView completionCallback:(void (^)(void))completionCallback target:(UIView *)target PushBackViewFrame:(CGRect)PushBackViewFrame duration:(NSTimeInterval)duration cloneView:(UIView *)cloneView {

    [self animateClonedViewByTransform3DIdentity:YES usingBlock:^(CAAnimation *caAnimation) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self animatePushBackView:PushBackView
                    completionCallback:completionCallback
                                target:target
                         PushBackViewFrame:PushBackViewFrame
                              duration:duration
                             cloneView:cloneView
                           caAnimation:caAnimation];
        });
    }];
}

// Determines how we will be manipulating the cloned root view and what sort of transition we'll be performing
-(void)animateClonedViewByTransform3DIdentity:(BOOL)transform3DIdentity usingBlock:(void(^)(CAAnimation *caAnimation))block {

    __block CABasicAnimation *animation;
    __block CABasicAnimation *animation2;
    __block CAAnimationGroup *group;



    CGFloat parentViewControllerHeight = self.parentViewController.view.frame.size.height;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        CATransform3D t1 = [self getTransformAnimation];
        CATransform3D t2 = [self getTransformAnimationUsingTransform:t1 usingParentVCHeight:parentViewControllerHeight];

        animation  = [self getAnimationUsingTransformAnimation:t1];
        animation2 = [self getAnimationUsingTransformIdentity:transform3DIdentity usingAnimation:animation withTransformAnimation:t2];

        dispatch_async(dispatch_get_main_queue(), ^{

            group = [self getGroup:animation usingAnimation:animation2];
            if(block) {
                block(group);
            }
        });
    });
}


-(void)animatePushBackView:(UIView *)PushBackView completionCallback:(void (^)(void))completionCallback target:(UIView *)target PushBackViewFrame:(CGRect)PushBackViewFrame duration:(NSTimeInterval)duration cloneView:(UIView *)cloneView caAnimation:(CAAnimation *)caAnimation {

    [cloneView.layer addAnimation:caAnimation forKey:@"pushedBackAnimation"];
    [UIView animateWithDuration:duration animations:^{
        cloneView.alpha = 0.5;
    }];

    [target addSubview:PushBackView];

    [UIView animateWithDuration:duration animations:^{

        PushBackView.frame = PushBackViewFrame;
        [self.view setHidden:YES];

    } completion:^(BOOL finished) {
        if (!finished) return;

        if(completionCallback) {
            completionCallback();
        }
    }];
}

-(void)animateAndRemovePushBackViewController:(UIViewController *)PushBackVC target:(UIView *)target modal:(UIView *)modal overlay:(UIView *)overlay {

    [UIView animateWithDuration:0.4 animations:^{
        modal.frame = CGRectMake(0, target.bounds.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {

        [overlay removeFromSuperview];
        [modal removeFromSuperview];

        [PushBackVC removeFromParentViewController];

        if ([PushBackVC respondsToSelector:@selector(endAppearanceTransition)]) {
            [PushBackVC endAppearanceTransition];
        }
    }];
}

// This method is called to restore the root view controller where it belongs, and removes the cloned view from our site.
-(void)restoreClonedView:(UIView *)clonedView withCompletion:(eLBeePBCompletionBlock)completion {

    [self animateClonedViewByTransform3DIdentity:NO usingBlock:^(CAAnimation *caAnimation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [clonedView.layer addAnimation:caAnimation forKey:@"bringForwardAnimation"];

            [UIView animateWithDuration:0.4 animations:^{
                clonedView.alpha = 1;
            } completion:^(BOOL finished) {

                if(!finished) return;

                [self.view setHidden:NO];
                [clonedView removeFromSuperview];

                if(completion) {
                    completion();
                }
            }];
        });
    }];
}

#pragma mark -
#pragma mark Transform Animation Methods
#pragma mark -

// All of these methods handle the 3D transformation of the view to give it the "push back" effect.

-(CABasicAnimation *)getAnimationUsingTransformAnimation:(CATransform3D)transformAnimation {

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transformAnimation];
    CFTimeInterval duration = 0.4;
    animation.duration = duration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

    return animation;
}

-(CABasicAnimation *)getAnimationUsingTransformIdentity:(BOOL)transform3DIdentity usingAnimation:(CABasicAnimation *)animation withTransformAnimation:(CATransform3D)transformAnimation {

    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(transform3DIdentity ? transformAnimation : CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;

    return animation2;
}


-(CATransform3D)getTransformAnimation {
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, (CGFloat) (15.0f*M_PI/180.0f), 1, 0, 0);
    return t1;
}

-(CATransform3D)getTransformAnimationUsingTransform:(CATransform3D)t1 usingParentVCHeight:(CGFloat)parentVCHeight {
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, parentVCHeight*-0.05, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    return t2;
}

-(CAAnimationGroup *)getGroup:(CABasicAnimation *)animation usingAnimation:(CABasicAnimation *)animation2 {
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}

@end
