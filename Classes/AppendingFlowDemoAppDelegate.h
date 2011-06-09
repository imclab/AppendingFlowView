//
//  AppendingFlowDemoAppDelegate.h
//
//  AppendingFlowView by Gregory S. Combs, based on work at https://github.com/grgcombs/AppendingFlowView
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import <UIKit/UIKit.h>

@class AppendingFlowDemoViewController;

@interface AppendingFlowDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AppendingFlowDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AppendingFlowDemoViewController *viewController;

@end
