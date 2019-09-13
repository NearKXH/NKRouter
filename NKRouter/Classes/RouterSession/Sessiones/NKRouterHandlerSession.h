//
//  NKRouterHandleSession.h
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import "NKRouterSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface NKRouterHandlerSession : NKRouterSession

- (instancetype)initWithHandler:(void (^)(NSDictionary * _Nullable parameters))handler;


@end

NS_ASSUME_NONNULL_END
