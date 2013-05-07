//
//  WebService.m
//  Zymurgy
//
//  Created by Adam Shiemke on 2/6/13.
//  Copyright (c) 2013 Adam Shiemke. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////
// Please read through the comments. This file will need to be modified considerably.
// It is provided only as a rough example and base for further work.
////////////////////////////////////////////////////////////////////////////////////////////////

#import "WebService.h"
#import "AFNetworking.h"
#import "AFNetworking/AFJSONRequestOperation.h"
#import "Magazine.h"

//Replace with your URL
#define kWebServiceBaseURL @"SOME_URL"

@implementation WebService

//Only needed if persisting a login across app starts
static NSString *token;
#define kTokenKey @"WSToken"

//Not needed for basic auth, since the token is stored as a cookie.
+(NSString*)loadToken{
    token = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenKey];
    return token;
}
+ (void) clearToken{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kTokenKey];
    token = @"";
}

//Simple login via post:
+ (void) loginWithUsername:(NSString*)username andPassword:(NSString*)password withCompletion:(void(^)(BOOL success))completion andError:(WSErrorBlock)errorBlock{
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kWebServiceBaseURL]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    //Simply post the username/password:
    NSDictionary *post = @{@"username":username, @"password":password};
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"/api/login/" parameters:post];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // JSON is id type, and should be either a dictionary, representing a JSON array ( {} ) or an NSArray representing an array( [] )
        // Type checking should be done here, prior to returning anything
        if (![JSON isKindOfClass:[NSDictionary class]]){
            copmletion(NO);
        }
        //Check for other cases. In this case, the API returns an ErrorMessage (which may or may not be blank) and a session token
        NSString *ErrorMessage = [JSON objectForKey:@"ErrorMessage"];
        token = [JSON objectForKey:@"MobileSessionId"];
        //validate our return values (and check classes)
        BOOL success = token && [token isKindOfClass:[NSString class]] && token.length > 0 && [ErrorMessage isKindOfClass:[NSNull class]];
        if (success){
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:kTokenKey];
            completion (YES);
        }
        else { // If something doesn't check out, call the error handler with the error message
            errorBlock([NSError errorWithDomain:@"com.webservice" code:0 userInfo:@{NSLocalizedDescriptionKey:ErrorMessage}]);
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        errorBlock(error);
    }];
    [operation start];
}
// Example call would look something like:
//
//    [WebService loginWithUsername:self.usernameField.text andPassword:self.passwordField.text withCompletion:^(BOOL success) {
//        [SVProgressHUD dismiss];
//        if (success){
//            [self performSegueWithIdentifier:@"pushNextScreen" sender:self];
//        }
//        else {
//            [SVProgressHUD showErrorWithStatus:@"Username or Password incorrect"];
//        }
//    } andError:^(NSError *error) {
//        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
//    }];



// Sample post which returns JSON
+ (void) searchWithText:(NSString*)searchString completion:(void(^)(NSArray* magazines))completion andError:(WSErrorBlock)errorBlock forceUpdate:(BOOL)force{
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kWebServiceBaseURL]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    // Add our token to the headder
    [client setDefaultHeader:@"MobileSessionId" value:token];
    //Create our post dictionary. Ignore if not posting
    NSDictionary *post = @{@"SearchTerms":searchString};
    
    //REPLACE WITH REAL PATH. If GETing then change POST to GET and the post param to nil
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"/api/issues/list" parameters:post];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // API returns an ErrorMessage in case of error:
        if ([[JSON objectForKey:@"ErrorMessage"] isKindOfClass:[NSString class]])  {
            NSError *e = [NSError errorWithDomain:@"com.webservice" code:0 userInfo:@{NSLocalizedDescriptionKey:[JSON objectForKey:@"ErrorMessage"]}];
            errorBlock(e);
            return;
        }
        // In this case, we get an array of objects back. These are converted to objective c objects and passed back in the completion handler.
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if ([JSON isKindOfClass:[NSDictionary class]]){
            if ([[JSON objectForKey:@"Issues"] isKindOfClass:[NSArray class]]){
                for (NSDictionary *d in [JSON objectForKey:@"Issues"]){
                    Magazine *mag = [Magazine magazineWithDictionary:d];
                    [arr addObject:mag];
                }
                //sort
                [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [((Magazine*)obj2).pubDate compare:((Magazine*)obj1).pubDate];
                }];
                completion(arr);
                return;
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        errorBlock(error);
    }];
    [operation start];
}

@end
