//
//  LIAViewController.m
//  IOSLinkedInAPI-Podexample
//
//  Created by Jacob von Eyben on 16/12/13.
//  Copyright (c) 2013 Eyben Consult ApS. All rights reserved.
//  Updated by Jeremy Hintz on 14/6/14

#import "LIAViewController.h"
#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
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

    // Form a query. In this example, we use first name, last name, email, and original picture url (for highest resolution)
    // For more information on what fields can be accessed, visit https://developer.linkedin.com/core-concepts
    NSString * query = [NSString stringWithFormat:@"first-name,last-name,email-address,picture-urls::(original);secure=true"];
    
    // We then form our API call, using the access token we received using our user's auth grant
    NSString * url = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(%@)?oauth2_access_token=%@&format=json", query, accessToken];
    
    // Finally, we make the call
    NSMutableURLRequest * urlRequest = [_client requestWithMethod:@"GET"
                                                             path:url
                                                       parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Data comes back, we put the JSON into an NSDictionary
        NSData * data = (NSData *)responseObject;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"JSON RETURNED: %@", json);
        // Do something with the JSON data here
        // Again, it would probably be useful to store this info in NSUserDefaults
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}


- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:REDIRECT_URL
                                                                                    clientId:CLIENT_ID
                                                                                clientSecret:CLIENT_SECRET
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_network", @"r_emailaddress"]];
    
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

@end
