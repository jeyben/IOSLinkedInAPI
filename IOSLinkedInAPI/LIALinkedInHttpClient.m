// LIALinkedInHttpClient.m
//
// Copyright (c) 2013 Ancientprogramming
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInAuthorizationViewController.h"
#import "NSString+LIAEncode.h"

#define LINKEDIN_TOKEN_KEY          @"linkedin_token"
#define LINKEDIN_EXPIRATION_KEY     @"linkedin_expiration"
#define LINKEDIN_CREATION_KEY       @"linkedin_token_created_at"

@interface LIALinkedInHttpClient ()
@property(nonatomic, strong) LIALinkedInApplication *application;
@property(nonatomic, weak) UIViewController *presentingViewController;
@end

@implementation LIALinkedInHttpClient

+ (LIALinkedInHttpClient *)clientForApplication:(LIALinkedInApplication *)application {
  return [self clientForApplication:application presentingViewController:nil];
}

+ (LIALinkedInHttpClient *)clientForApplication:(LIALinkedInApplication *)application presentingViewController:viewController {
  LIALinkedInHttpClient *client = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.linkedin.com"]];
  client.application = application;
  client.presentingViewController = viewController;
  return client;
}


- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (self) {
    [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
  }
  return self;
}

- (BOOL)validToken {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

  if ([[NSDate date] timeIntervalSince1970] >= ([userDefaults doubleForKey:LINKEDIN_CREATION_KEY] + [userDefaults doubleForKey:LINKEDIN_EXPIRATION_KEY])) {
    return NO;
  }
  else {
    return YES;
  }
}

- (NSString *)accessToken {
  return [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_TOKEN_KEY];
}

- (void)getAccessToken:(NSString *)authorizationCode success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
  NSString *accessTokenUrl = @"/uas/oauth2/accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@";
  NSString *url = [NSString stringWithFormat:accessTokenUrl, authorizationCode, [self.application.redirectURL LIAEncode], self.application.clientId, self.application.clientSecret];

  [self POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *accessToken = [responseObject objectForKey:@"access_token"];
    NSTimeInterval expiration = [[responseObject objectForKey:@"expires_in"] doubleValue];

    // store credentials
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:accessToken forKey:LINKEDIN_TOKEN_KEY];
    [userDefaults setDouble:expiration forKey:LINKEDIN_EXPIRATION_KEY];
    [userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:LINKEDIN_CREATION_KEY];
    [userDefaults synchronize];

    success(responseObject);
  }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  }];

}

- (void)getAuthorizationCode:(void (^)(NSString *))success cancel:(void (^)(void))cancel failure:(void (^)(NSError *))failure {
  LIALinkedInAuthorizationViewController *authorizationViewController = [[LIALinkedInAuthorizationViewController alloc]
      initWithApplication:
          self.application
                  success:^(NSString *code) {
                    [self hideAuthenticateView];
                    if (success) {
                      success(code);
                    }
                  }
                   cancel:^{
                     [self hideAuthenticateView];
                     if (cancel) {
                       cancel();
                     }
                   } failure:^(NSError *error) {
        [self hideAuthenticateView];
        if (failure) {
          failure(error);
        }
      }];
  [self showAuthorizationView:authorizationViewController];
}

- (void)showAuthorizationView:(LIALinkedInAuthorizationViewController *)authorizationViewController {
  if (self.presentingViewController == nil)
    self.presentingViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;

  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:authorizationViewController];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
  }

  [self.presentingViewController presentViewController:nc animated:YES completion:nil];
}

- (void)hideAuthenticateView {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
