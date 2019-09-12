//
//  NKRouterSession.m
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import "NKRouterSession.h"

#import "NSError+NKRouter.h"

@implementation NKRouterSession

- (void)sessionRequest:(NKRouterRequest *)request completionHandler:(void (^)(BOOL, NSDictionary * _Nullable, NSError * _Nullable))completionHandler {
    completionHandler(false, nil, [NSError _NKRouter_responseErrorCode:NKRouterResponseErrorSessionNotRealize]);
}

@end
