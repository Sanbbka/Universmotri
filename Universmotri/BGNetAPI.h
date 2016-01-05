//
//  Created by Alexandr Okhotnikov on 13.05.13.
//  Copyright (c) 2013 ЗАО "БАРС Груп". All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


//API call completion block with result as json
typedef void (^JSONResponseBlock)(BOOL success, NSDictionary *json);


@interface BGNetAPI : NSObject

@property (strong, nonatomic) NSURL *address;
@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *token;

//для сервисов BI
@property (strong, nonatomic) NSURL *addressBI2;
@property (strong, nonatomic) NSString *loginBI2;
@property (strong, nonatomic) NSString *passwordBI2;
@property (strong, nonatomic) NSString *tokenBI2;


+ (BGNetAPI*)sharedInstance;

+ (void)updateLogin:(NSString*)login pass:(NSString*)pass token:(NSString*)token;

+ (void)logout;

+ (BOOL)inetAvaiable;
+ (void)netActivityVisible;
+ (void)netActivityHide;

//send an API command to the server
+ (NSURLSessionDataTask*)commandWithPath:(NSString *)path
                                  params:(NSDictionary*)params
                                  method:(NSString*)method
                                  cached:(BOOL)cached
                            onCompletion:(JSONResponseBlock)completionBlock;

+ (NSURLSessionDataTask*)commandWithPathBI2:(NSString *)path
                                     params:(NSDictionary*)params
                                     method:(NSString*)method
                                     cached:(BOOL)cached
                               onCompletion:(JSONResponseBlock)completionBlock;

+ (void)autorizWithComplection:(JSONResponseBlock)complectionBlock;
+ (void)autorizWithComplectionBI2:(JSONResponseBlock)complectionBlock;

+ (void) clearCookieAndCancelHTTPOperations;

+ (NSString*)urlEncodeFromString:(NSString*)str;

+ (void)versionNumberFromPlistUrl:(NSString*)strUrl complection:(void(^)(NSString *bundleNumber))complectionBlock;
+ (NSString*)bundleName;

+ (void)saveKeychain:(NSString *)service data:(id)data;
+ (id)loadKeychain:(NSString *)service;
+ (void)deleteKeychain:(NSString *)service;

@end
