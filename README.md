eLBeePushBackController
=======================

![ScreenShot 1](screenshot.png)


Update (July 14, 2013): Added a push/dismiss Modal view example.
Note: The modal view is actually hidden from the main view.  To view it, open the storyboard, click the main view 
controller, and you'll see a white box between the first responder (red cube) and Exit segue (green exit square).  

Just drag the white box (which is the view) onto the viewcontroller to edit/view it.  its up to you if you want to put 
it back (you can just drag it from interface builder to the bottom bar and it will automatically hide).


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

Finally, here is a quick demo of how to use it (this is alsoincluded project under, Example).  

It includes 2 buttons: a Push controller button and a Modal button.

## Example

#### MainViewController.m
```objective-c

#import "MainViewController.h"
#import "ModalViewController.h"
#import "UIViewController+eLBeePushBackController.h"

@interface MainViewController() <ModalVCDelegate>

@property (nonatomic, weak) IBOutlet UIView *modalView;

@end

@implementation MainViewController

-(IBAction)pushBackVCDelegateShouldDismissController:(id)sender {
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


// Modal View Example:
-(IBAction)presentPushBackModalViewBtn:(id)sender {
    [self presentPushBackView:self.modalView withCompletion:^{
        NSLog(@"Modal View was presented!");
    }];
}

-(IBAction)dismissModalViewBtn {
    [self dismissPushBackViewWithCompletion:^{
       NSLog(@"Modal View was dismissed!");
    }];
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

This is released under the MIT License - checkout LICENSE for more information.

Thanks, hope you find this useful!!


## Resources
[KNSemiModal](https://github.com/kentnguyen/KNSemiModalViewController)

[Stackoverflow - UIView Cloning](http://stackoverflow.com/a/13664732)


## Contact Info

Website: [http://phpadvocate.com/](http://phpadvocate.com/)

LinkedIn: [http://www.linkedin.com/in/jhibbard/](http://www.linkedin.com/in/jhibbard/)

Twitter: [https://twitter.com/infolock](https://twitter.com/infolock)
