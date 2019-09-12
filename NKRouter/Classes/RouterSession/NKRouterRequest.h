//
//  NKRouterRequest.h
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NKRouterMatchType) {
    NKRouterMatchTypeNone,          // can not match any registered url and without undefined session
    NKRouterMatchTypeExact,         // match exactly
    NKRouterMatchTypeOption,        // match url with option path
    NKRouterMatchTypeWildcard,      // match url by wildcard
    NKRouterMatchTypeUndefined,     // match url by undefined session
};


@interface NKRouterRequest : NSObject 

@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) NSDictionary *parameters; // union requestUrlQuery and requestExtraParameters, key-value which in extra parameters will be used, when the key both in requestUrlQuery and requestExtraParameters


@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *requestUrlQuery;
@property (nonatomic, strong, nullable) NSDictionary *requestExtraParameters;


@property (nonatomic, assign) NKRouterMatchType matchType;
@property (nonatomic, strong, nullable) NSString *matchPath;


@end

NS_ASSUME_NONNULL_END
