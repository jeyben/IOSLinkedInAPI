IOSLinkedInAPI
==============
A small non intrucive project that makes is easy to authenticate and authorize against LinkedIn using OAuth2.

You end up with an accesstoken used to retrieve data from the LinkedIn api [https://developer.linkedin.com/apis]

Example
-------

A LinkedIn client is created using a LIALinkedInApplication.
A LIALinkedInApplication defines the application which is granted access to the users linkedin data.
``` objective-c
LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com"
                                                                                    clientId:@"clientId"
                                                                                clientSecret:@"clientSecret"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_network"]];
LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application];
```
* redirectURL: has to be a valid http or https url, but other than that, the endpoint doesn't have to respond anything.
* clientId: The id which is provided by LinkedIn, when registering an application.
* clientSecret: The secret which is provided by LinkedIn, when registering an application.
* grantedAccess: An array telling which access the application would like to be granted by the enduser. See full list here: http://developer.linkedin.com/documents/authentication

Afterwards the client can be used to retrieve an accesstoken:
``` objective-c
client getAuthorizationCode:^(NSString * code) {
    [self.client getAccessToken:code success:^(NSDictionary *accessToken) {
        NSLog(@"fetched accesstoken %@", accessToken);
    } failure:^(NSError *error) {
        NSLog(@"Quering accessToken failed %@", error);
    }];
} cancel:^{
    NSLog(@"Authorization was cancelled by user");
} failure:^(NSError *error) {
    NSLog(@"Authorization failed %@", error);
}];

```