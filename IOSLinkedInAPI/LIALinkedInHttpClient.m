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
#import "AFJSONRequestOperation.h"
#import "LIALinkedInAuthorizationViewController.h"

@interface LIALinkedInHttpClient ()
@property(nonatomic, strong) LIALinkedInApplication *application;
@end

@implementation LIALinkedInHttpClient
+ (LIALinkedInHttpClient *)clientForApplication:(LIALinkedInApplication *)application {
    LIALinkedInHttpClient *client = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.linkedin.com"]];
    client.application = application;
    return client;
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Content-Type" value:@"application/json"];
        // This is to make AFNetworking format parameters against server as JSON
        self.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}

- (void)getAccessToken:(NSString *)authorizationCode success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    NSString *accessTokenUrl = @"/uas/oauth2/accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@";
    NSString *url = [NSString stringWithFormat:accessTokenUrl, authorizationCode, self.application.redirectURL, self.application.clientId, self.application.clientSecret];
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *accessToken) {
        success(accessToken);
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootViewController presentViewController:authorizationViewController animated:YES completion:nil];
}

- (void)hideAuthenticateView {
    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
