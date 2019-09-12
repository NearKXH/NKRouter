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


+ (BOOL)registerUrl:(NSString *)url handler:(void (^)(NSDictionary * _Nullable parameters))handler;
- (BOOL)registerUrlPath:(NSString *)urlPath handler:(void (^)(NSDictionary * _Nullable parameters))handler;


+ (BOOL)registerUrl:(NSString *)url session:(__kindof NKRouterSession *)session;
- (BOOL)registerUrlPath:(NSString *)urlPath session:(__kindof NKRouterSession *)session;


- (void)unregisterUrlPath:(NSString *)urlPath;
- (void)unregisterAllUrl;


+ (BOOL)canRouteUrl:(NSString *)url;
- (BOOL)canRouteUrl:(NSString *)url;


+ (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;
+ (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;


- (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;
- (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler;


@end

NS_ASSUME_NONNULL_END
