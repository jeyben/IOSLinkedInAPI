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


    NSArray *grantedAccess = @[@"r_fullprofile", @"r_network"];
    NSString *state = @"DCEEFWF45453sdffef424"; //A long unique string value of your choice that is hard to guess. Used to prevent CSRF
    //load the the secret data from an uncommitted LIALinkedInClientExampleCredentials.h file
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com" clientId:LINKEDIN_CLIENT_ID clientSecret:LINKEDIN_CLIENT_SECRET state:state grantedAccess:grantedAccess];
    LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end