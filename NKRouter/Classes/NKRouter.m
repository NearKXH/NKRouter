//
//  NKRouter.m
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/30.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import "NKRouter.h"

#import "NKRouterRequest.h"
#import "NKRouterResponse.h"
#import "NKRouterSession.h"
#import "NKRouterHandlerSession.h"

#import "NKRouterRequest+Private.h"
#import "NKRouterResponse+Private.h"

NKRouterSchemeName const NKRouterGlobalScheme = @"__NKRouter_GlobalSchemeKey";

static NSString * const _NKRouter_PathComponentsMapOptionKey = @":option";
static NSString * const _NKRouter_PathComponentsMapWildcardKey = @"*";

static NSString * const _NKRouter_PathComponentsMapSessionKey = @":session";
static NSString * const _NKRouter_PathComponentsMapLevelKey = @":level";
static NSString * const _NKRouter_PathComponentsMapPathKey = @":path";

static NSMutableDictionary *_NKRouter_SchemeCollectionMap = nil;
static NSLock *_NKRouter_SchemeCollectionMapLock = nil;



@interface NKRouter ()
@property (nonatomic, copy, readwrite) NKRouterSchemeName scheme;

@property (nonatomic, strong) NSMutableDictionary *pathComponentsMap;
@property (nonatomic, strong) NSLock *pathComponentsMapLock;

@property (atomic, strong, nullable) NKRouterSession *undefinedSession;

@end

@implementation NKRouter

#pragma mark - initialize
/// Returns the global routing scheme
+ (instancetype)globalRouter {
    return [self routerForScheme:NKRouterGlobalScheme];
}

/// Returns a routing namespace for the given scheme
+ (instancetype)routerForScheme:(NKRouterSchemeName)scheme {
    if (!scheme.length) return nil;
    
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _NKRouter_SchemeCollectionMap = NSMutableDictionary.new;
        _NKRouter_SchemeCollectionMapLock = NSLock.new;
        _NKRouter_SchemeCollectionMapLock.name = @"_NKRouter_SchemeLock";
    });
    
    NKRouter *router = nil;
    [_NKRouter_SchemeCollectionMapLock lock];
    router = _NKRouter_SchemeCollectionMap[scheme];
    if (!router) {
        router = [[NKRouter alloc] initWithScheme:scheme];
        _NKRouter_SchemeCollectionMap[scheme] = router;
    }
    [_NKRouter_SchemeCollectionMapLock unlock];

    return router;
}

/// Unregister and delete an entire scheme namespace
+ (void)unregisterRouterScheme:(NKRouterSchemeName)scheme {
    if (!scheme.length) return;
    
    [_NKRouter_SchemeCollectionMapLock lock];
    [_NKRouter_SchemeCollectionMap removeObjectForKey:scheme];
    [_NKRouter_SchemeCollectionMapLock unlock];
}

/// Unregister all routes
+ (void)unregisterAllRouters {
    [_NKRouter_SchemeCollectionMapLock lock];
    [_NKRouter_SchemeCollectionMap removeAllObjects];
    [_NKRouter_SchemeCollectionMapLock unlock];
}

- (instancetype)initWithScheme:(NKRouterSchemeName)scheme {
    self = [super init];
    if (self) {
        _scheme = scheme;
        _pathComponentsMap = NSMutableDictionary.new;
        _pathComponentsMapLock = NSLock.new;
        _pathComponentsMapLock.name = [NSString stringWithFormat:@"_NKRouter_RouterLock_Scheme:%@", scheme];
    }
    return self;
}


#pragma mark - Register
+ (BOOL)registerUrl:(NSString *)url handler:(void (^)(NSDictionary * _Nullable))handler {
    NKRouterHandlerSession *session = [[NKRouterHandlerSession alloc] initWithHandler:handler];
    return [self registerUrl:url session:session];
}

+ (BOOL)registerUrl:(NSString *)url session:(__kindof NKRouterSession *)session {
    NSURLComponents *components = [NSURLComponents componentsWithString:(url ?: @"")];
    NKRouter *router = components.scheme.length ? [self routerForScheme:components.scheme] : [self globalRouter];
    return [router _registerUrlComponents:components session:session unregister:false];
}

- (BOOL)registerUrlPath:(NSString *)urlPath handler:(void (^)(NSDictionary * _Nullable))handler {
    NKRouterHandlerSession *session = [[NKRouterHandlerSession alloc] initWithHandler:handler];
    return [self registerUrlPath:urlPath session:session];
}

- (BOOL)registerUrlPath:(NSString *)urlPath session:(__kindof NKRouterSession *)session {
    NSURLComponents *components = [NSURLComponents componentsWithString:(urlPath ?: @"")];
    return [self _registerUrlComponents:components session:session unregister:false];
}

- (void)unregisterUrlPath:(NSString *)urlPath {
    NSURLComponents *components = [NSURLComponents componentsWithString:(urlPath ?: @"")];
    [self _registerUrlComponents:components session:nil unregister:true];
}

- (void)unregisterAllUrl {
    [self.pathComponentsMapLock lock];
    [self.pathComponentsMap removeAllObjects];
    [self.pathComponentsMapLock unlock];
}


#pragma mark - Router Url
+ (BOOL)canRouteUrl:(NSString *)url {
    NSURLComponents *components = [NSURLComponents componentsWithString:(url ?: @"")];
    NKRouter *router = components.scheme.length ? [self routerForScheme:components.scheme] : [self globalRouter];
    return [router _routeUrlComponents:components parameters:nil completionHandler:nil executeRoute:false];
}

- (BOOL)canRouteUrl:(NSString *)url {
    NSURLComponents *components = [NSURLComponents componentsWithString:(url ?: @"")];
    return [self _routeUrlComponents:components parameters:nil completionHandler:nil executeRoute:false];
}

+ (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler {
    [self routeUrl:url parameters:nil completionHandler:completionHandler];
}

+ (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler {
    NSURLComponents *components = [NSURLComponents componentsWithString:(url ?: @"")];
    NKRouter *router = components.scheme.length ? [self routerForScheme:components.scheme] : [self globalRouter];
    [router _routeUrlComponents:components parameters:parameters completionHandler:completionHandler executeRoute:true];
}

- (void)routeUrl:(NSString *)url completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler {
    [self routeUrl:url parameters:nil completionHandler:completionHandler];
}

- (void)routeUrl:(NSString *)url parameters:(nullable NSDictionary<NSString *, id> *)parameters completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler {
    NSURLComponents *components = [NSURLComponents componentsWithString:(url ?: @"")];
    [self _routeUrlComponents:components parameters:parameters completionHandler:completionHandler executeRoute:true];
}


#pragma mark - Private
#pragma mark register
- (BOOL)_registerUrlComponents:(NSURLComponents *)urlComponents session:(NKRouterSession *)session unregister:(BOOL)isUnregister {
    if (!session && !isUnregister) return false;
    
    NSArray *pathComponents = [self _pathComponentsWithPath:urlComponents.path];
    if (!pathComponents.count) return false;
    
    [self.pathComponentsMapLock lock];
    NSMutableDictionary *pathComponentsMap = self.pathComponentsMap;
    NSInteger level = 1;
    NSMutableArray *mapPaths = NSMutableArray.new;
    for (NSString *path in pathComponents) {
        NSString *pathKey = path;
        if ([pathKey hasPrefix:@":"]) {
            pathKey = _NKRouter_PathComponentsMapOptionKey;
        }
        [mapPaths addObject:pathKey];
        
        NSMutableDictionary *subPathComponentsMap = pathComponentsMap[pathKey];
        if (!subPathComponentsMap) {
            subPathComponentsMap = NSMutableDictionary.new;
            subPathComponentsMap[_NKRouter_PathComponentsMapLevelKey] = @(level);
            pathComponentsMap[pathKey] = subPathComponentsMap;
        }
        pathComponentsMap = subPathComponentsMap;
        
        if ([pathKey isEqualToString:_NKRouter_PathComponentsMapWildcardKey]) {
            break;
        }
        
        level++;
    }
    pathComponentsMap[_NKRouter_PathComponentsMapSessionKey] = session;
    pathComponentsMap[_NKRouter_PathComponentsMapPathKey] = [mapPaths componentsJoinedByString:@"/"];
    [self.pathComponentsMapLock unlock];
    
    return true;
}

#pragma mark route
- (BOOL)_routeUrlComponents:(NSURLComponents *)urlComponents
                 parameters:(nullable NSDictionary<NSString *, id> *)parameters
          completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler
               executeRoute:(BOOL)isExecute {
    if (!isExecute && self.undefinedSession) return true;
    
    NKRouterMatchType matchType = NKRouterMatchTypeExact;
    
    NKRouterSession *session = nil;
    NSString *sessionPath = nil;
    
    NSInteger wildcardSessionLevel = -1;
    NKRouterSession *wildcardSession = nil;
    NSString *wildcardPath = nil;
    
    NSArray<NSString *> *pathComponents = [self _pathComponentsWithPath:urlComponents.path];
    NSMutableArray *nodeArray = NSMutableArray.new;
    
    [self.pathComponentsMapLock lock];
    NSDictionary *nodeDic = [self.pathComponentsMap copy];
    [self.pathComponentsMapLock unlock];
    
    while (nodeDic || nodeArray.count) {
        NSInteger currentLevel = [nodeDic[_NKRouter_PathComponentsMapLevelKey] integerValue];
        if (currentLevel == pathComponents.count) {
            if (nodeDic[_NKRouter_PathComponentsMapSessionKey]) {
                session = nodeDic[_NKRouter_PathComponentsMapSessionKey];
                sessionPath = nodeDic[_NKRouter_PathComponentsMapPathKey];
                break;
            } else if (wildcardSessionLevel < currentLevel && nodeDic[_NKRouter_PathComponentsMapWildcardKey][_NKRouter_PathComponentsMapSessionKey]) {
                wildcardSessionLevel = currentLevel;
                wildcardSession = nodeDic[_NKRouter_PathComponentsMapWildcardKey][_NKRouter_PathComponentsMapSessionKey];
                wildcardPath = nodeDic[_NKRouter_PathComponentsMapWildcardKey][_NKRouter_PathComponentsMapPathKey];
            }
            nodeDic = nil;
        }
        
        if (nodeDic) {
            NSString *key = pathComponents[currentLevel];
            [nodeArray addObject:nodeDic];
            nodeDic = nodeDic[key];
        } else {
            nodeDic = nodeArray.lastObject;
            [nodeArray removeLastObject];
            
            matchType = NKRouterMatchTypeOption;
            
            if (wildcardSessionLevel < currentLevel && nodeDic[_NKRouter_PathComponentsMapWildcardKey][_NKRouter_PathComponentsMapSessionKey]) {
                wildcardSessionLevel = currentLevel ;
                wildcardSession = nodeDic[_NKRouter_PathComponentsMapWildcardKey][_NKRouter_PathComponentsMapSessionKey];
                wildcardPath = nodeDic[_NKRouter_PathComponentsMapWildcardKey][_NKRouter_PathComponentsMapPathKey];
            }
            nodeDic = nodeDic[_NKRouter_PathComponentsMapOptionKey];
        }
    }
    
    if (isExecute) {
        return [self _executeSession:(session ?: wildcardSession)
                       urlComponents:urlComponents
                           matchPath:sessionPath
                           matchType:(session ? matchType : NKRouterMatchTypeWildcard)
                          parameters:parameters
                   completionHandler:completionHandler];
    } else {
        return session || wildcardSession || self.undefinedSession;
    }
}

- (BOOL)_executeSession:(NKRouterSession *)session
          urlComponents:(NSURLComponents *)urlComponents
              matchPath:(NSString *)matchPath
              matchType:(NKRouterMatchType)matchType
             parameters:(nullable NSDictionary<NSString *, id> *)parameters
      completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler {
    
    NKRouterSession *exeSession = session;
    if (!exeSession) {
        exeSession = self.undefinedSession;
        matchType = NKRouterMatchTypeUndefined;
    }
    
    if (exeSession) {
        NKRouterRequest *request = [NKRouterRequest request:urlComponents parameters:parameters matchType:matchType matchPath:matchPath];
        NKRouterRequest *requestRsp = [request copy];
        [exeSession sessionRequest:request completionHandler:^(BOOL succeed, NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
            if (completionHandler) {
                NKRouterResponse *response = [NKRouterResponse responseWithRequest:requestRsp succeed:succeed responseObject:responseObject error:error];
                completionHandler(response);
            }
        }];
        
    } else if (completionHandler) {
        NKRouterResponse *response = [NKRouterResponse invalidMatchResponseUrl:urlComponents.string parameters:parameters];
        completionHandler(response);
    }
    
    return exeSession;
    
}


#pragma mark pathComponents
- (NSArray<NSString *> *)_pathComponentsWithPath:(NSString *)path {
    NSMutableArray *array = [[path componentsSeparatedByString:@"/"] mutableCopy];
    [array removeObject:@""];
    return array;
}


#pragma mark - description
#ifdef DEBUG
- (NSString *)description {
    return [super description];
}

- (NSString *)DebugDescription {
    return [self description];
}

#endif

@end
