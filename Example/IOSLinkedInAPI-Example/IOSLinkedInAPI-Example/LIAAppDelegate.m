//
//  LIAAppDelegate.m
//  IOSLinkedInAPI-Example
//
//  Created by Jacob von Eyben on 04/27/13.
//  Copyright (c) 2013 Ancientprogramming. All rights reserved.
//

#import "LIAAppDelegate.h"

@implementation LIAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.


  self.viewController = [[LIALinkedInExampleViewController alloc] init];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end