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
#import "NKRouterHandleSession.h"

NKRouterSchemeName const NKRouterSchemeGlobal = @"__NKRouter_SchemeGlobalKey";

static NSString * const _NKRouter_PathComponentsMapSessionKey = @"__NKRouter_PathComponentsMap_SessionKey";
static NSString * const _NKRouter_PathComponentsMapOptionKey = @":option";

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
    return [self routerForScheme:NKRouterSchemeGlobal];
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
        router = NKRouter.new;
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
+ (BOOL)registerUrl:(NSString *)url handle:(void (^)(NSDictionary * _Nullable))handle {
    NKRouterHandleSession *session = [[NKRouterHandleSession alloc] initWithHandle:handle];
    return [self registerUrl:url session:session];
}

+ (BOOL)registerUrl:(NSString *)url session:(__kindof NKRouterSession *)session {
    NSURLComponents *components = [NSURLComponents componentsWithString:(url ?: @"")];
    NKRouter *router = components.scheme.length ? [self routerForScheme:components.scheme] : [self globalRouter];
    return [router _registerUrlComponents:components session:session unregister:false];
}

- (BOOL)registerUrlPath:(NSString *)urlPath handle:(void (^)(NSDictionary * _Nullable))handle {
    NKRouterHandleSession *session = [[NKRouterHandleSession alloc] initWithHandle:handle];
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

- (void)setupUndefinedUrlSession:(nullable __kindof NKRouterSession *)session {
    self.undefinedSession = session;
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
    for (NSString *path in pathComponents) {
        NSString *pathKey = path;
        if ([pathKey hasPrefix:@":"]) {
            pathKey = _NKRouter_PathComponentsMapOptionKey;
        }
        
        NSMutableDictionary *subPathComponentsMap = pathComponentsMap[pathKey];
        if (!subPathComponentsMap) {
            subPathComponentsMap = NSMutableDictionary.new;
            pathComponentsMap[pathKey] = subPathComponentsMap;
        }
        pathComponentsMap = subPathComponentsMap;
        
        if ([pathKey isEqualToString:@"*"]) {
            break;
        }
        
    }
    pathComponentsMap[_NKRouter_PathComponentsMapSessionKey] = session;
    [self.pathComponentsMapLock unlock];
    
    return true;
}

#pragma mark route
- (BOOL)_routeUrlComponents:(NSURLComponents *)urlComponents
                 parameters:(nullable NSDictionary<NSString *, id> *)parameters
          completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler
               executeRoute:(BOOL)isExecute {
    if (!isExecute && self.undefinedSession) return true;
    
    NSArray *pathComponents = [self _pathComponentsWithPath:urlComponents.path];
    if (!pathComponents.count) {
        if (isExecute) {
            [self _executeSession:nil urlComponents:urlComponents parameters:parameters completionHandler:completionHandler];
        }
        return false;
    }
    
    [self.pathComponentsMapLock lock];
    NSDictionary *pathComponentsMap = [self.pathComponentsMap copy];
    [self.pathComponentsMapLock unlock];
    
    NSMutableArray *nodeArray = NSMutableArray.new;
    NSDictionary *nodeDic = pathComponentsMap;
    NSInteger currentLevel = 0;
    NKRouterSession *session = nil;
    NSInteger undefinedSessionLevel = 0;
    NKRouterSession *undefinedSession = nil;
    while (nodeDic || nodeArray.count) {
//        if (<#condition#>) {
//            <#statements#>
//        }
        if (nodeDic) {
            
        } else {
            nodeDic = nodeArray.lastObject;
        }
    }
    
    
    
    if (isExecute) {
        [self _executeSession:session urlComponents:urlComponents parameters:parameters completionHandler:completionHandler];
    }
    
    return session;
}

- (void)_executeSession:(NKRouterSession *)session
          urlComponents:(NSURLComponents *)urlComponents
             parameters:(nullable NSDictionary<NSString *, id> *)parameters
      completionHandler:(nullable void (^)(NKRouterResponse *response))completionHandler {
    NKRouterSession *exeSession = session ?: self.undefinedSession;
    if (exeSession) {
        
    } else if (completionHandler) {
        NKRouterResponse *response = nil;
        completionHandler(response);
    }
}


#pragma mark pathComponents
- (NSArray<NSString *> *)_pathComponentsWithPath:(NSString *)path {
    NSMutableArray *array = [[path componentsSeparatedByString:@"/"] mutableCopy];
    [array removeObject:@""];
//    if (path.length && [path hasPrefix:@"/"]) {
//        path = [path substringFromIndex:1];
//    }
//    NSArray *array = [path componentsSeparatedByString:@"/"];
    
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
