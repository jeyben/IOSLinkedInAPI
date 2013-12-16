//
//  LIAAppDelegate.h
//  IOSLinkedInAPI-Example
//
//  Created by Jacob von Eyben on 04/27/13.
//  Copyright (c) 2013 Ancientprogramming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LIALinkedInExampleViewController.h"



@interface LIAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LIALinkedInExampleViewController *viewController;

@end