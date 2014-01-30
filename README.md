IOSLinkedInAPI
==============
A small non intrucive library that makes it easy to authenticate and authorize against LinkedIn using OAuth2.
The API uses a UIWebView to authenticate against LinkedIn.
 
<p align="center" >
  <img src="https://raw.github.com/jeyben/IOSLinkedInAPI/master/gh-pages/authenticate-example-iphone.png" alt="Authentication" title="Authentication" height="417" width="207">
</p>
<p align="center" >
  <img src="https://raw.github.com/jeyben/IOSLinkedInAPI/master/gh-pages/authenticate-example-ipad.png" alt="Authentication" title="Authentication" height="568" width="440">
</p>

If the enduser is authenticated you end up with an accesstoken that is nessesary to retrieve data from the LinkedIn [API](https://developer.linkedin.com/apis)

Why this library?
-----------------
Why yet another LinkedIn library?
Although there already exists a couple of iOS libraries which is wrapping the LinkedIn API, none of them *(at least to my knowledge)* is using OAuth2 which is the preferred protocol according to LinkedIn.

How To Get Started
------------------
The library can be fetched as a Pod from [cocoapods](http://cocoapods.org/?q=ioslinkedinapi)

If you aren't using Cocoapods you can always download the libary and import the files from the folder IOSLinkedInAPI into your existing project.

Example Code
------------

A LinkedIn client is created using a LIALinkedInApplication.
A LIALinkedInApplication defines the application which is granted access to the users linkedin data.
``` objective-c
LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                  clientId:@"clientId"
                                                                              clientSecret:@"clientSecret"
                                                                                     state:@"DCEEFWF45453sdffef424"
                                                                             grantedAccess:@[@"r_fullprofile", @"r_network"]];
return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
```
* redirectURL: has to be a http or https url (required by LinkedIn), but other than that, the endpoint doesn't have to respond anything. The library only uses the endpoint to know when to intercept calls in the UIWebView.
* clientId: The id which is provided by LinkedIn upon registering an application.
* clientSecret: The secret which is provided by LinkedIn upon registering an application.
* state: the state used to prevent Cross Site Request Forgery. Should be something that is hard to guess.
* grantedAccess: An array telling which access the application would like to be granted by the enduser. See full list here: http://developer.linkedin.com/documents/authentication
* presentingViewController: The view controller that the UIWebView will be modally presented from.  Passing nil assumes the root view controller.

Afterwards the client can be used to retrieve an accesstoken and access the data using the LinkedIn API:
``` objective-c
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
```
The code example retrieves an access token and uses it to get userdata for the user which granted the access.
The cancel callback is executed in case the user actively declines the authorization by pressing cancel button in the UIWebView (see illustration above).
The failure callbacks is executed in case either the of the steps fails for some reason.

Example App
------------
A small example application can be found here:
https://github.com/jeyben/IOSLinkedInAPI/tree/master/Example/IOSLinkedInAPI-Podexample/IOSLinkedInAPI-Podexample

It uses the cocoapods.
Just run 'pods install' in the directory after your clone and you should be able to run the app afterwards


Next step
--------------------
The library is currently  handling the authentication and authorization.
I would like to improve the libary to also make it easy to do the actually API calls.
My current thought is to let the client remember the accessToken after it is retrieved and afterwards automatically append it to futher calls along with the format=json GET parameter.

If you have ideas of how that could be implemented let me know.

http://www.ancientprogramming.com
