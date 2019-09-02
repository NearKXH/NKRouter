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
extern NKRouterSchemeName const NKRouterSchemeGlobal;

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


+ (BOOL)registerUrl:(NSString *)url handle:(void (^)(NSDictionary * _Nullable))handle;
- (BOOL)registerUrlPath:(NSString *)urlPath handle:(void (^)(NSDictionary * _Nullable))handle;


+ (BOOL)registerUrl:(NSString *)url session:(__kindof NKRouterSession *)session;
- (BOOL)registerUrlPath:(NSString *)urlPath session:(__kindof NKRouterSession *)session;


- (void)setupUndefinedUrlSession:(nullable __kindof NKRouterSession *)session;


@end

NS_ASSUME_NONNULL_END
