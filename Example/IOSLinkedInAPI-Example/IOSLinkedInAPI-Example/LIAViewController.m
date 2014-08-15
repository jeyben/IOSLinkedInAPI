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
#import "AFHTTPRequestOperation.h"

@interface LIAViewController ()

@property(nonatomic, strong) LIALinkedInHttpClient *client;
@end

@implementation LIAViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *grantedAccess = @[@"r_fullprofile", @"r_network"];

    //load the the secret data from an uncommitted LIALinkedInClientExampleCredentials.h file
    NSString *clientId = LINKEDIN_CLIENT_ID; //the client secret you get from the registered LinkedIn application
    NSString *clientSecret = LINKEDIN_CLIENT_SECRET; //the client secret you get from the registered LinkedIn application
    NSString *state = @"DCEEFWF45453sdffef424"; //A long unique string value of your choice that is hard to guess. Used to prevent CSRF
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com" clientId:clientId clientSecret:clientSecret state:state grantedAccess:grantedAccess];
    self.client = [LIALinkedInHttpClient clientForApplication:application];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(0, 0, 300, 44);
    loginButton.center = CGPointMake(CGRectGetMidX(self.view.frame), 50);
    [loginButton setTitle:@"Login to LinkedIn" forState:UIControlStateNormal];
    [self.view addSubview:loginButton];

    [loginButton addTarget:self action:@selector(didPressLogin:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didPressLogin:(id)sender {
    NSLog(@"did press login");
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
                NSLog(@"current user %@", result);
            }            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failed to fetch current user %@", error);
            }];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                          cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                         failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
