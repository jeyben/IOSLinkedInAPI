//
//  LIAViewController.m
//  IOSLinkedInAPI-Podexample
//
//  Created by Jacob von Eyben on 16/12/13.
//  Copyright (c) 2013 Eyben Consult ApS. All rights reserved.
//

#import "LIAViewController.h"
#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInClientExampleCredentials.h"
#import "LIALinkedInApplication.h"

@interface LIAViewController ()

@end

@implementation LIAViewController {
  LIALinkedInHttpClient *_client;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _client = [self client];
}


- (IBAction)didTapConnectWithLinkedIn:(id)sender {
  [self.client getAuthorizationCode:^(NSString *code) {
    [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
      NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
      [self requestMeWithToken:accessToken];
    }                   failure:^(NSError *error) {
      NSLog(@"Quering accessToken failed %@", error);
    }];
  }                      cancel:^{
    NSLog(@"Authorization was cancelled by user");
  }                     failure:^(NSError *error) {
    NSLog(@"Authorization failed %@", error);
  }];
}


- (void)requestMeWithToken:(NSString *)accessToken {
  [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
    NSLog(@"current user %@", result);
  }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"failed to fetch current user %@", error);
  }];
}

- (LIALinkedInHttpClient *)client {
  LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                  clientId:LINKEDIN_CLIENT_ID
                                                                              clientSecret:LINKEDIN_CLIENT_SECRET
                                                                                     state:@"DCEEFWF45453sdffef424"
                                                                             grantedAccess:@[@"r_fullprofile", @"r_network"]];
  return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

@end
