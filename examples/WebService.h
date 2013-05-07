//
//  WebService.h
//  Zymurgy
//
//  Created by Adam Shiemke on 2/6/13.
//  Copyright (c) 2013 Adam Shiemke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WSErrorBlock)(NSError *error);

@class Magazine;

@interface WebService : NSObject

+ (NSString*) loadToken;
+ (void) clearToken;

+ (void) loginWithUsername:(NSString*)username andPassword:(NSString*)password withCompletion:(void(^)(BOOL success))completion andError:(WSErrorBlock)errorBlock;

+ (void) searchWithText:(NSString*)searchString completion:(void(^)(NSArray* magazines))completion andError:(WSErrorBlock)errorBlock forceUpdate:(BOOL)force;

@end
