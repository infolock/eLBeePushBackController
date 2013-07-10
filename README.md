eLBeePushBackController
=======================

## About

This is a simple UIViewController Category for creating a semi modal / push back transition.

I built this category after trying to determine how to best refine kentnguyen's KNSemiModal category. I was actually going to just make a few changes and then issue a pull request, but after having changed the code so heavily, I've decided to just release it as a spin-off of KNSemiModal instead.

### Biggest Changes

* Renamed it from KNSemiModal to eLBeePushBackController (ok, I know that is obvious...)
* Renamed presentSemiViewController to be presentPushBackController to ensure we don't conflict with KNSemiModal should you use it in the same build
* Refactored a lot of the animation code and split things out into more managiable chunks (@see getAnimationUsingTransformIdentity methods. These need to be combined into a single method though - @todo ;)
* Added blocks and GCD to improve performance
* I resize the initial "root uiview" of the callee controller rather than creating a screenshot. autoresizingMask is used instead to just shrink/manipulate the view (didn't feel I gained anything via screenshots)
* Removed all objc runtime properties as they aren't exactly necessary

### Addition(s):
* Created a UIView+Clone category for creating a weak-referenced clone of views. (This can easily be changed to be strong by just removing __weak)

### In Development:
* I'm working on some new transition styles so that you can choose which transition to use
* Created a helper method to define the percentage to shrink the pushback view

### Things I removed:
* Removed "presentSemiView". Why? Because I never used it and only used this for controllers. I plan to add it back when I need it though ...
* the Dismiss block for the present methods (temporarily). Going to decide how to handle this later (will probably create a simpe NSNotification call rather than storing it with objc runtime properties)
* The most important thing I removed was calls to "shouldRasterize" and "rasterizationScale". These 2 calls create awful responses and just aren't worth the little details they offer with this code. I'm not hating on rasterize - just saying - it sucks here =)
* Removed all of the traversal searches for the parentview. I just personally didn't need it and found it slowed stuff down. If you want it - let me know and I'll add it (or create a pull request!)
* Removed the shadow layers - again, slowed the animation down and I quite honestly just didn't care if shadows were shown or not
* All objc_runtime properties (obviously)
* All of the define methods (replaced the tags with NS_ENUM instead)
* All of the subclasses/categories
* Removed the "options" param (I never used it personally - if you do - sorry =)
* Removed the screenshot creation

### Things that I kept/borrowed/whatever from KNSemiModal:
* The transform3d logic for scaling/rotating
* callback methods for completion
* some of the animation routines
* the overlay view

Finally, here is a quick example of how to use it.  Check out the example in the included project to see it live.

## Example

#### MainViewController.m
```objective-c

#import "MainViewController.h"
#import "ModalViewController.h"
#import "UIViewController+eLBeePushBackController.h"

@interface MainViewController() <ModalVCDelegate>
@end

@implementation MainViewController

-(IBAction)showAction:(id)sender {

    ModalViewController *modalVC = (ModalViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewControllerSBID"];
    modalVC.delegate = self;  // This is not necessary - is good to just let your main view handle presenting/dismissing
    [self presentPushBackController:modalVC];
    /**
     * Or...
     * [self presentPushBackController:modalVC withCompletion:^{ someMagicMethodHere() }];
     */
}

-(void)pushBackVCDelegateShouldDismissController:(ModalViewController)controller {
    [self dismissPushBackController:controller];
    /**
     * Or...
     * [self dismissPushBackController:modalVC withCompletion:^{ someMagicMethodHere() }];
     */
    controller.delegate = nil;
}
@end
```

#### ModalViewController.h
```objective-c

#import <UIKit/UIKit.h>

@class ModalViewController;
@protocol ModalVCDelegate <NSObject>
-(void)pushBackVCDelegateShouldDismissController:(ModalViewController *)controller;
@end

@interface ModalViewController : UIViewController
@property (nonatomic, weak) id <ModalVCDelegate> delegate;
@end
```
#### ModalViewController.m
```objective-c

#import "ModalViewController.h"

@interface ModalViewController()
-(IBAction)dismissAction;
@end


@implementation ModalViewController

-(IBAction)dismissAction {
    [self.delegate pushBackVCDelegateShouldDismissController:self];
}

@end
```


## Gotchas

* UIViewController+eLBeePushBackController.h is where you can manipulate the sizes, tags, etc of the views. It is currently very limited. This will be removed soon with a more proper implementation. For now, it is what it is.
* There is not much comments currently. This, too, should change soon enough.


Thanks, hope you find this useful!!
