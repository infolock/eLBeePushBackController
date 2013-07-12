eLBeePushBackController
=======================

![ScreenShot 1](screenshot.png)


## About

eLBeePushBackController us a simple, lightweight UIViewController Category for creating a semi modal / push back transition.  

This code was originally a fork of [kentnguyen's](https://github.com/kentnguyen) [KNSemiModal](https://github.com/kentnguyen/KNSemiModalViewController) category.  

### Biggest Changes

* Refactored a lot of the animation code and split things out into more manageable chunks.
* Added blocks and GCD
* Replaced the screenshot resize for the push back animation transition with just a simple resizing of the main view.
* Removed a bunch of other logic I wasn't needing
* Rewrote almsot all of the non-CATransform3DTranslate methods/logic
* Currently, its now just under 220 lines (from 348)


### In Development:
* I'm working on some new transition styles so that you can choose which transition to use

### Things I removed:
* Removed "presentSemiView"
* the Dismiss block for the present methods (temporarily).
* Removed calls to "shouldRasterize" and "rasterizationScale".
* Removed all of the traversal searches for the parentview.
* Removed the shadow layers
* All objc_runtime properties
* All of the define methods
* All of the subclasses/categories
* Removed the "options" param
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


Thanks, hope you find this useful!!


## Resources
[KNSemiModal](https://github.com/kentnguyen/KNSemiModalViewController)

[Stackoverflow - UIView Cloning](http://stackoverflow.com/a/13664732)


## Contact Info

Website: [http://phpadvocate.com/](http://phpadvocate.com/)

LinkedIn: [http://www.linkedin.com/in/jhibbard/](http://www.linkedin.com/in/jhibbard/)

Twitter: [https://twitter.com/infolock](https://twitter.com/infolock)
