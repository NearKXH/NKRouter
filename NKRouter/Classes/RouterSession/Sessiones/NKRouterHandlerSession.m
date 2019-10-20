//
//  NKRouterHandleSession.m
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import "NKRouterHandlerSession.h"

@interface NKRouterHandlerSession ()

@property (nonatomic, copy) void (^handler)(NSDictionary *);


@end

@implementation NKRouterHandlerSession

- (instancetype)initWithHandler:(void (^)(NSDictionary * _Nonnull))handler {
    self = [super init];
    if (self) {
        self.handler = handler;
    }
    return self;
}

- (void)sessionRequest:(NKRouterRequest *)request completionHandler:(void (^)(BOOL, NSDictionary * _Nullable, NSError * _Nullable))completionHandler {
    if (_handler && [NSThread isMainThread]) {
        _handler(request.parameters);
        completionHandler(true, nil, nil);
    } else if (_handler && ![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _handler(request.parameters);
            completionHandler(true, nil, nil);
        });
    } else {
        completionHandler(true, nil, nil);
    }
}


@end
