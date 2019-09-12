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
    NKRouterMatchTypeNone,
    NKRouterMatchTypeComplete,
    NKRouterMatchTypeOption,
    NKRouterMatchTypeWildcard,
    NKRouterMatchTypeUndefined,
};


@interface NKRouterRequest : NSObject 

@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) NSDictionary *parameters;


@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *requestUrlQuery;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *requestExtraParameters;


@property (nonatomic, assign) NKRouterMatchType matchType;
@property (nonatomic, strong, nullable) NSString *matchPath;


@end

NS_ASSUME_NONNULL_END
