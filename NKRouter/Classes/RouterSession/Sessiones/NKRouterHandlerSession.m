//
//  NKRouterHandleSession.m
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import "NKRouterHandlerSession.h"

@interface NKRouterHandlerSession ()

@property (nonatomic, copy) void (^handler)(NSDictionary<NSString *, id> *);

@end

@implementation NKRouterHandlerSession

- (instancetype)initWithHandler:(void (^)(NSDictionary<NSString *, id> * _Nonnull))handler {
    self = [super init];
    if (self) {
        self.handler = handler;
    }
    return self;
}

- (void)sessionRequest:(NKRouterRequest *)request completionHandler:(void (^)(BOOL, NSDictionary * _Nullable, NSError * _Nullable))completionHandler {
    if (_handler) {
        _handler(request.parameters);
    }
    completionHandler(true, nil, nil);
}

@end
