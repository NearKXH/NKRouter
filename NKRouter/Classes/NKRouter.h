//
//  NKRouter.h
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/30.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NKRouterResponse.h"

NS_ASSUME_NONNULL_BEGIN

@class NKRouterSession;

typedef NSString *NKRouterSchemeName NS_EXTENSIBLE_STRING_ENUM;

// For globalRouter
extern NKRouterSchemeName const NKRouterGlobalScheme;

@interface NKRouter : NSObject

/// Returns the global routing scheme, using NKRouterSchemeGlobal as scheme
+ (instancetype)globalRouter;

/// Returns a routing namespace for the given scheme
+ (instancetype)routerForScheme:(NKRouterSchemeName)scheme;
@property (nonatomic, copy, readonly) NKRouterSchemeName scheme;

/// Unregister and delete an entire scheme namespace
+ (void)unregisterRouterScheme:(NKRouterSchemeName)scheme;

/// Unregister all routes
+ (void)unregisterAllRouters;


@end


@interface NKRouter (RegisterUrl)

/**
 register url using router which scheme is equal to url's scheme
 If the scheme of the url is empty, globalRouter will be used

 @param url register url path
 @param handler called on main thread when url is matched 
 @return true, if register succeed. False, if url path is empty (e.g. http://eg or http://eg////)
 */
+ (BOOL)registerUrl:(NSString *)url handler:(void (^)(NSDictionary * _Nullable parameters))handler;

/// register url with handler
- (BOOL)registerUrlPath:(NSString *)urlPath handler:(void (^)(NSDictionary * _Nullable parameters))handler;


/**
 register url path using router which scheme is equal to url's scheme
 If the scheme of the url is empty, globalRouter will be used

 @param url register url path
 @param session method sessionRequest:completionHandler: called when router match url
 @return true, if register succeed. False, if url path is empty (e.g. http://eg or http://eg////)
 */
+ (BOOL)registerUrl:(NSString *)url session:(__kindof NKRouterSession *)session;

/// register url with session
- (BOOL)registerUrlPath:(NSString *)urlPath session:(__kindof NKRouterSession *)session;


/// unregister url path
- (void)unregisterUrlPath:(NSString *)urlPath;
/// unregister all url
- (void)unregisterAllUrl;


/**
 when the url can not be routed, undefined session will be called
 */
@property (atomic, strong, nullable) NKRouterSession *undefinedSession;


@end


@interface NKRouter (RouteUrl)

/**
 Algorithm Summary:
 - Match algorithm uses 'DFS' and 'DLR' 'non-recursion' algorithm
 - URL route request will trigger once only by the most exact URL route.
 
 Algorithm Detail:
 NKRouter matches the most exact URL route.
 - Router matches the same directory firstly, then go to match the next directory if matched.
 - Otherwise router matches the optional parameter secoedly, then go to match the next directory if matched.
 - Router go back to previous directory if neither directorys do not exist.
 - Finally, the routing session, which matched the whole path, will be executed.
 
 For example, the URL route request 'app/home/view' would be triggered for the following registered URL orderly:
 - app/home/view
 - app/home/:option
 - app/:option/view
 - app/:option/:option
 - :option/home/view
 - :option/home/:option
 - :option/:option/view
 - :option/:option/:option
 
 Route with wildcards will be matched if the registered URL above can not be found. The match algorithm of wildcards is similar:
 - app/home/view/ *
 - app/home/:option/ *
 - app/home/ *
 - app/:option/ *
 - app/ *
 - :option/ *
 - *
 
 'Undefined Session' will be triggered if exist and wildcards do not exist neither.
 
 At the end, URL route 'completionHandler' called with invalid response parameter, if all of the route above do not exist.
 
 */


/**
 check url path whether had been registered
 If the scheme of the url is empty, globalRouter will be used
 
 @param url check url path
 @return True, if the url path had been registered, or undefinedSession is not null
 */
+ (BOOL)canRouteUrl:(NSString *)url;
/// check url path whether had been registered
- (BOOL)canRouteUrl:(NSString *)url;


/**
 route url path using router which scheme is equal to url's scheme
 If the scheme of the url is empty, globalRouter will be used
 
 @param url route by url path, url query as query parameters
 @param completionHandler call when session had been finished. Note: completionHandler will be called on main thread
 */
+ (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;

/// route url path
- (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;


/**
 route url path using router which scheme is equal to url's scheme
 If the scheme of the url is empty, globalRouter will be used

 @param url route by url path, url query as query parameters
 @param parameters extra parameters
 @param completionHandler call when session had been finished. Note: completionHandler will be called on main thread
 */
+ (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;

/// route url path
- (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;


@end

NS_ASSUME_NONNULL_END
