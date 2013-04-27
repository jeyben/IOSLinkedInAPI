//
//  LIAViewController.m
//  IOSLinkedInAPI-Example
//
//  Created by Jacob von Eyben on 04/27/13.
//  Copyright (c) 2013 Ancientprogramming. All rights reserved.
//

#import "LIAViewController.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInClientExampleCredentials.h"

@interface LIAViewController ()

@end

@implementation LIAViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //load the the secret data from an uncommitted LIALinkedInClientExampleCredentials.h file
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com" clientId:LINKEDIN_CLIENT_ID clientSecret:LINKEDIN_CLIENT_SECRET];
    LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end