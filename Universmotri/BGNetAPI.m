//
//  Created by Alexandr Okhotnikov on 13.05.13.
//  Copyright (c) 2013 ЗАО "БАРС Груп". All rights reserved.
//

#import "BGNetAPI.h"
#import "BGTools.h"

@interface BGNetAPI ()
@property (nonatomic, assign) NSInteger netActivityVisible;
@property (nonatomic, strong) NSDictionary *addHttpHeaders;
@end


@implementation BGNetAPI

@synthesize address;

#pragma mark - Singleton methods

+ (BGNetAPI*)sharedInstance
{
    static BGNetAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - init

- (BGNetAPI*)init
{
    self = [super init];
    
    if (self != nil) {
        self.netActivityVisible = 0;
        
        self.address = [NSURL URLWithString:@"http://alpha.bars-open.ru/alpha/pf/"];
        
        //debug
        self.login    = @"admin";
        self.password = @"entry";
        self.token    = @"xxx";
        
        
//        [self loadLogin];
        
        //get host, login, password from Preferences
        [self loadLoginBI2];
        self.tokenBI2    = @"xxx";
        
        NSURLCache* myCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                            diskCapacity:20 * 1024 * 1024
                                                                diskPath:nil];
        [NSURLCache setSharedURLCache:myCache];
    }
    return self;
}

- (void)loadLogin
{
    NSMutableDictionary *userDefaults = [BGNetAPI loadKeychain:nil];
    if (userDefaults) {
        self.login    = [userDefaults objectForKey:@"login"];
        self.password = [userDefaults objectForKey:@"password"];
        self.token    = [userDefaults objectForKey:@"token"];
    }
}

- (void)loadLoginBI2
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.addressBI2 = [NSURL URLWithString:[defaults stringForKey:@"host_bi_preference"]];
    self.loginBI2    = [defaults stringForKey:@"login_bi_preference"];
    self.passwordBI2 = [defaults stringForKey:@"password_bi_preference"];
    
}

+ (void)updateLogin:(NSString*)login pass:(NSString*)pass token:(NSString*)token
{
    [self clearCookieAndCancelHTTPOperations];

    BGNetAPI *net = [BGNetAPI sharedInstance];

    NSString *keyLogin = @"login";
    NSString *keyPass  = @"password";
    NSString *keyToken = @"token";
    net.login    = login;
    net.password = pass;
    net.token    = token;
    
    NSMutableDictionary *userDefaults = [BGNetAPI loadKeychain:nil];
    if (! userDefaults)
        userDefaults = [NSMutableDictionary dictionary];
    if (login && login.length > 0)
        [userDefaults setObject:login forKey:keyLogin];
    else
        [userDefaults removeObjectForKey:keyLogin];
    if (pass && pass.length > 0)
        [userDefaults setObject:pass forKey:keyPass];
    else
        [userDefaults removeObjectForKey:keyPass];
    if (token && token.length > 0)
        [userDefaults setObject:token forKey:keyToken];
    else
        [userDefaults removeObjectForKey:keyToken];
    [BGNetAPI saveKeychain:nil data:userDefaults];
}


+ (void)logout
{
    BGNetAPI *net = [BGNetAPI sharedInstance];
    
    net.password = nil;

    [self clearCookieAndCancelHTTPOperations];

    // сбрасываем пароль
    NSMutableDictionary *userDefaults = [BGNetAPI loadKeychain:nil];
    if (userDefaults) {
        [userDefaults removeObjectForKey:@"password"];
        [userDefaults removeObjectForKey:@"token"];
        
        [BGNetAPI saveKeychain:nil data:userDefaults];
    }

}



#pragma mark - сетевая часть

+ (void) clearCookieAndCancelHTTPOperations
{
    BGNetAPI *apiSelf = [BGNetAPI sharedInstance];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if (apiSelf.address != nil)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
                [storage deleteCookie:cookie];
        }
//        if (apiSelf.net != nil) {
//            [apiSelf.net cancelAllHTTPOperations];
//            apiSelf.net = nil;
//        }
    }
}

+ (BOOL)inetAvaiable
{
    return YES;
}

+ (void)cancelAllHTTPOperationsWithPath:(NSString *)path
{
//    [[BGNetAPI sharedInstance].net cancelAllHTTPOperationsWithPath:path];
}

+ (void)cancelAllHTTPOperations
{
//    [[BGNetAPI sharedInstance].net cancelAllHTTPOperations];
}

+ (NSURLSessionDataTask*)commandWithPath:(NSString *)path
                                  params:(NSDictionary*)params
                                  method:(NSString*)method
                                  cached:(BOOL)cached
                            onCompletion:(JSONResponseBlock)completionBlock
{
    return [self sendRequestWithPath:path params:params method:method cached:cached retryCount:0 onCompletion:completionBlock];
}

+ (NSURLSessionDataTask*)commandWithPathBI2:(NSString *)path
                                     params:(NSDictionary*)params
                                     method:(NSString*)method
                                     cached:(BOOL)cached
                               onCompletion:(JSONResponseBlock)completionBlock
{
    return [self sendRequestWithPathBI2:path params:params method:method cached:cached retryCount:0 onCompletion:completionBlock];
}

+ (NSURLSessionDataTask*)sendRequestWithPath:(NSString*)path
                                      params:(NSDictionary*)params
                                     method:(NSString*)method
                                     cached:(BOOL)cached
                                 retryCount:(NSInteger)retryCount
                               onCompletion:(JSONResponseBlock)completionBlock
{
    BGNetAPI *net = [BGNetAPI sharedInstance];
    
    NSURL *url;
    BOOL isHostAlphaBI = YES;
    if ([path hasPrefix:@"http"]) {
        url = [NSURL URLWithString:path];
        isHostAlphaBI = NO;
    }
    else
        url = [NSURL URLWithString:path relativeToURL:net.address];
    
    NSMutableURLRequest *request;
    NSMutableDictionary *addHeader = [NSMutableDictionary dictionaryWithDictionary:net.addHttpHeaders];
    
    NSMutableDictionary *copyParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if (isHostAlphaBI && net.token && net.token.length > 0)
        [copyParams setObject:net.token forKey:@"authToken"];
    
    if (copyParams[@"BGNETAPI_auth"]) {
        NSDictionary *auth = copyParams[@"BGNETAPI_auth"];
        [copyParams removeObjectForKey:@"BGNETAPI_auth"];
        if (auth[@"type"] && [auth[@"type"] isEqualToString:@"basic"]) {
            NSString *basic = [NSString stringWithFormat:@"%@:%@", auth[@"user"], auth[@"password"]];
            NSData *authData = [basic dataUsingEncoding:NSUTF8StringEncoding];
            [addHeader setValue:[NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]] forKey:@"Authorization"];
        }
    }
    
    if ([method isEqualToString:@"XMLPOST"])
    {
        request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[url absoluteString]] ];
        request.HTTPMethod = @"POST";
        [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
        
        NSString *bodyString = copyParams[@"body"];
        [request setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        NSString *soapAction = copyParams[@"SOAPAction"];
        if (soapAction != nil)
            [request setValue: (soapAction.length>0 ? [NSString stringWithFormat:@"%@://%@/%@", [url scheme], [url host], copyParams[@"SOAPAction"]] : soapAction) forHTTPHeaderField:@"SOAPAction"];
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([method isEqualToString:@"POST"])
    {
        request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[url absoluteString]] ];
        request.HTTPMethod = method;
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        if (copyParams && copyParams.count > 0) {
            NSString *bodyString;
            [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            bodyString = stringFromParameters(copyParams);
            request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        }
    }
    else
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        if (copyParams && copyParams.count > 0)
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", stringFromParameters(copyParams)]];
        else
            url = [NSURL URLWithString:[url absoluteString]];
        
        request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method;
    }
    
    if (addHeader) {
        for (NSString *key in addHeader) {
            [request setValue:addHeader[key] forHTTPHeaderField:key];
        }
    }

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
//    [sessionConfig setHTTPAdditionalHeaders:addHeader];
    sessionConfig.requestCachePolicy = ([self inetAvaiable] ? (cached ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringCacheData) : NSURLRequestReturnCacheDataDontLoad);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [self netActivityVisible];
    
#ifdef DEBUG
//    NSLog(@"NET: %@: url=%@, HTTPHeaders=%@, HTTPBody=%@\n\n", method, request.URL.absoluteString, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"NET: %@: url=%@\n\n", method, request.URL.absoluteString);
#endif
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [self netActivityHide];
        
        if (error.code == NSURLErrorCancelled)
            return;

        BOOL success = NO;
        NSDictionary *json = nil;
        NSInteger code = 0;
        
        if (error)
            code = error.code;
        else
            code = ((NSHTTPURLResponse*)response).statusCode;
        
        if (code == 401 || code == 403)
        {
            if (retryCount <= 0)
            {
                [self autorizWithComplection:^(BOOL success, NSDictionary *json) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            [self sendRequestWithPath:path params:params method:method cached:cached retryCount:retryCount+1 onCompletion:completionBlock];
                        }
                        else {
                            completionBlock(success, json);
                        }
                    });
                }];
                return;
            }
            json = @{@"error_msg" : @"Данные недоступны. Неверный логин или пароль...", @"error_code" : @(code)};
        }
        else if (code == 200)
        {
            //                NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse*)response allHeaderFields] forURL:response.URL];
            //                NSLog(@"%@", cookies);
            
            NSString *contentType = ((NSHTTPURLResponse*)response).allHeaderFields[@"Content-Type"];
            if (contentType != nil && [contentType hasPrefix:@"text/xml;"]) {
                json = @{ @"data" : [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] };
                success = YES;
            }
            else if (contentType != nil && [contentType hasPrefix:@"text/plain"]) {
                json = @{ @"data" : [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] };
                success = YES;
            }
            else {
                NSError *jsonError;
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:&jsonError];
                if (json) {
                    if ([json isKindOfClass:[NSDictionary class]]) {
                        if (! [BGTools jsonGetBool:json[@"error"]]) {
                            success = YES;
                        }
                        else {
                            json = @{ @"error_msg" : [BGTools jsonGetString:json[@"data"]] };
                            code = 1002;
                        }
                    }
                    else
                        code = 1001;
                }
                else {
                    //TODO временно !!!!!!!!!!!!!!!!!!!!!!
                    if (retryCount <= 0 && isHostAlphaBI)
                    {
                        [self autorizWithComplection:^(BOOL success, NSDictionary *json) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (success) {
                                    [self sendRequestWithPath:path params:params method:method cached:cached retryCount:retryCount+1 onCompletion:completionBlock];
                                }
                                else {
                                    completionBlock(success, json);
                                }
                            });
                        }];
                        return;
                    }
                    code = 1000;
                }
            }
        }
        else {
            NSLog(@"net error: %@ %@\n %@\n\n", method, ((NSHTTPURLResponse*)response).allHeaderFields, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
        }
        
        if (! json) {
            json = @{@"error_msg" : ([self inetAvaiable] ? @"Данные недоступны. Попробуйте позже..." : @"Данные недоступны (нет доступа к интернету)"), @"error_code" : @(code)};
            NSLog(@"%@", json);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(success, json);
        });
    }];
    
    [jsonData resume];
    
    return jsonData;
}


//запросы для сервера BI
+ (NSURLSessionDataTask*)sendRequestWithPathBI2:(NSString*)path
                                         params:(NSDictionary*)params
                                         method:(NSString*)method
                                         cached:(BOOL)cached
                                     retryCount:(NSInteger)retryCount
                                   onCompletion:(JSONResponseBlock)completionBlock
{
    BGNetAPI *net = [BGNetAPI sharedInstance];
    
    [net loadLoginBI2];
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:net.addressBI2];
    
    NSMutableURLRequest *request;
    NSMutableDictionary *addHeader = [NSMutableDictionary dictionaryWithDictionary:net.addHttpHeaders];
    
    NSMutableDictionary *copyParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if ([method isEqualToString:@"POST"])
    {
        request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[url absoluteString]] ];
        request.HTTPMethod = method;
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        if (copyParams && copyParams.count > 0) {
            NSString *bodyString;
            [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            bodyString = stringFromParameters(copyParams);
            request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        }
    }else if ([method isEqualToString:@"GET"])
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        if (copyParams && copyParams.count > 0)
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", stringFromParameters(copyParams)]];
        else
            url = [NSURL URLWithString:[url absoluteString]];
        
        request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method;
    }
    
    if (addHeader) {
        for (NSString *key in addHeader) {
            [request setValue:addHeader[key] forHTTPHeaderField:key];
        }
    }
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
    //    [sessionConfig setHTTPAdditionalHeaders:addHeader];
    sessionConfig.requestCachePolicy = ([self inetAvaiable] ? (cached ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringCacheData) : NSURLRequestReturnCacheDataDontLoad);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [self netActivityVisible];
    
#ifdef DEBUG
    //    NSLog(@"NET: %@: url=%@, HTTPHeaders=%@, HTTPBody=%@\n\n", method, request.URL.absoluteString, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"NET: %@: url=%@\n\n", method, request.URL.absoluteString);
#endif
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [self netActivityHide];
        
        if (error.code == NSURLErrorCancelled)
            return;
        
        BOOL success = NO;
        NSDictionary *json = nil;
        NSInteger code = 0;
        
        if (error)
            code = error.code;
        else
            code = ((NSHTTPURLResponse*)response).statusCode;
        
        if (code == 401 || code == 403)
        {
            if (retryCount <= 0)
            {
                [self autorizWithComplectionBI2:^(BOOL success, NSDictionary *json) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            [self sendRequestWithPathBI2:path params:params method:method cached:cached retryCount:retryCount+1 onCompletion:completionBlock];
                        }
                        else {
                            completionBlock(success, json);
                        }
                    });
                }];
                return;
            }
            json = @{@"error_msg" : @"Данные недоступны. Неверный логин или пароль...", @"error_code" : @(code)};
        }
        else if (code == 200)
        {
            //                NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse*)response allHeaderFields] forURL:response.URL];
            //                NSLog(@"%@", cookies);
            
            NSString *contentType = ((NSHTTPURLResponse*)response).allHeaderFields[@"Content-Type"];
            if (contentType != nil && [contentType hasPrefix:@"text/xml;"]) {
                json = @{ @"data" : [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] };
                success = YES;
            }
            else if (contentType != nil && [contentType hasPrefix:@"text/plain"]) {
                json = @{ @"data" : [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] };
                success = YES;
            }
            else {
                NSError *jsonError;
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:&jsonError];
                if (json) {
                    if ([json isKindOfClass:[NSDictionary class]]) {
                        if (! [BGTools jsonGetBool:json[@"error"]]) {
                            success = YES;
                        }
                        else {
                            json = @{ @"error_msg" : [BGTools jsonGetString:json[@"data"]] };
                            code = 1002;
                        }
                    }
                    else
                        code = 1001;
                }
                else {
                    //TODO временно !!!!!!!!!!!!!!!!!!!!!!
                    if (retryCount <= 0)
                    {
                        [self autorizWithComplectionBI2:^(BOOL success, NSDictionary *json) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (success) {
                                    [self sendRequestWithPathBI2:path params:params method:method cached:cached retryCount:retryCount+1 onCompletion:completionBlock];
                                }
                                else {
                                    completionBlock(success, json);
                                }
                            });
                        }];
                        return;
                    }
                    code = 1000;
                }
            }
        }
        else {
            NSLog(@"net error: %@ %@\n %@\n\n", method, ((NSHTTPURLResponse*)response).allHeaderFields, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
        }
        
        if (! json) {
            json = @{@"error_msg" : ([self inetAvaiable] ? @"Данные недоступны. Попробуйте позже..." : @"Данные недоступны (нет доступа к интернету)"), @"error_code" : @(code)};
            NSLog(@"%@", json);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(success, json);
        });
    }];
    
    [jsonData resume];
    
    return jsonData;
}

#pragma mark - user

+ (void)autorizWithComplection:(JSONResponseBlock)complectionBlock
{
    BGNetAPI *net = [BGNetAPI sharedInstance];
    
    if (!net.login && !net.password) {
        complectionBlock(NO, nil);
        return;
    }
    
	[self sendRequestWithPath:@"login/login" params:@{@"login":net.login, @"password":net.password} method:@"POST" cached:NO retryCount:1000 onCompletion:^(BOOL success, NSDictionary *json) {
        NSString *errStr;
        if (success) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                if ([BGTools jsonGetBool:json[@"Success"]])
                    net.token = [BGTools jsonGetString:json[@"TokenValue"]];
                else
                    errStr = [BGTools jsonGetString:json[@"Error"]];
            }
        }
        if (net.token == nil || net.token.length <= 0) {
            json = @{@"error_msg" : [NSString stringWithFormat:@"Данные недоступны. (%@)", (errStr?:@"Неверный логин или пароль...")], @"error_code" : @(403)};
        }
        complectionBlock(success, json);
    }];
}

+ (void)autorizWithComplectionBI2:(JSONResponseBlock)complectionBlock
{
    BGNetAPI *net = [BGNetAPI sharedInstance];
    
    [self sendRequestWithPathBI2:@"login/login" params:@{@"Login":net.loginBI2, @"Password":net.passwordBI2} method:@"POST" cached:NO retryCount:1000 onCompletion:^(BOOL success, NSDictionary *json) {
        NSString *errStr;
        if (success) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                if ([BGTools jsonGetBool:json[@"Success"]])
                    net.tokenBI2 = [BGTools jsonGetString:json[@"TokenValue"]];
                else
                    errStr = [BGTools jsonGetString:json[@"Error"]];
            }
        }
        if (net.tokenBI2 == nil || net.tokenBI2.length <= 0) {
            json = @{@"error_msg" : [NSString stringWithFormat:@"Данные недоступны. (%@)", (errStr?:@"Неверный логин или пароль...")], @"error_code" : @(403)};
        }
        complectionBlock(success, json);
    }];
}

#pragma mark - utils

+ (void)netActivityVisible
{
    BGNetAPI *apiSelf = [BGNetAPI sharedInstance];

    if (apiSelf.netActivityVisible <= 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    ++apiSelf.netActivityVisible;
}

+ (void)netActivityHide
{
    BGNetAPI *apiSelf = [BGNetAPI sharedInstance];

    --apiSelf.netActivityVisible;
    if (apiSelf.netActivityVisible == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (NSString*)urlEncodeFromString:(NSString*)str
{
    return urlEncode( str, NSUTF8StringEncoding );
}

static NSString* stringFromParameters(NSDictionary *params)
{
    if (! params)
        return @"";
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *key in params) {
        NSString *field = urlEncode( key, NSUTF8StringEncoding );
        NSString *value = urlEncode( [NSString stringWithFormat:@"%@", params[key]], NSUTF8StringEncoding);
        [arr addObject:[NSString stringWithFormat:@"%@=%@", field ?: @"", value ?: @""]];
    }
    
    return [arr componentsJoinedByString:@"&"];
}

static NSString* urlEncode(NSString *str, NSStringEncoding encoding)
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)str,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}


#pragma mark - скачать plist и вытащить версию бандла

+ (void)versionNumberFromPlistUrl:(NSString*)strUrl complection:(void(^)(NSString *bundleNumber))complectionBlock
{
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSString *bundle = nil;
            NSError *errorPlist;
            NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&errorPlist];
            if (!errorPlist && dict && dict[@"items"]) {
                NSArray *arr = dict[@"items"];
                if (arr && [arr isKindOfClass:[NSArray class]] && arr.count > 0) {
                    for (NSDictionary *item in arr) {
                        if ([item isKindOfClass:[NSDictionary class]] && item[@"metadata"]) {
                            NSDictionary *meta = item[@"metadata"];
                            if ([meta isKindOfClass:[NSDictionary class]] && meta[@"bundle-version"]) {
                                bundle = meta[@"bundle-version"];
                            }
                        }
                    }
                }
            }
            complectionBlock(bundle);
        }
        else {
            NSLog(@"!!!DEBUG versionNumberFromPlistUrl!!! error = %ld, %@", (long)error.code, error);
        }
    }];
}

+ (NSString*)bundleName
{
    NSString *bundleName = [self bundleID];
    NSRange range = [bundleName rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location != NSNotFound && range.length > 0) {
        bundleName = [bundleName substringFromIndex:range.location+1];
    }
    return bundleName;
}

+ (NSString*)bundleID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
}

#pragma mark - Keychain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    if (service == nil)
        service = [self bundleID];

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)saveKeychain:(NSString *)service data:(id)data
{
    if (service == nil)
        service = [self bundleID];

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)loadKeychain:(NSString *)service
{
    if (service == nil)
        service = [self bundleID];
    
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

+ (void)deleteKeychain:(NSString *)service
{
    if (service == nil)
        service = [self bundleID];

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end

