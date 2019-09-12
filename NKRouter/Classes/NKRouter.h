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


/**
 register url using router which scheme is equal to url's scheme
 If the scheme of the url is empty, globalRouter will be used

 @param url register url path
 @param handler called when url is matched
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
 @param completionHandler call when session had been finished
 */
+ (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;

/// route url path
- (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;


/**
 route url path using router which scheme is equal to url's scheme
 If the scheme of the url is empty, globalRouter will be used

 @param url route by url path, url query as query parameters
 @param parameters extra parameters
 @param completionHandler call when session had been finished
 */
+ (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;

/// route url path
- (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;


@end

NS_ASSUME_NONNULL_END
