//
//  NKRouterResponse.h
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NKRouterRequest.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NKRouterResponseErrorDomain;
typedef NS_ENUM(NSUInteger, NKRouterResponseError) {
    /// can not match any url
    NKRouterResponseErrorNotMatch = -9001,
    /// session which inherited do not realize sessionRequest:completionHandler: or used the base session
    NKRouterResponseErrorSessionNotRealize,
};


@interface NKRouterResponse : NSObject

@property (nonatomic, assign) BOOL succeed;
@property (nonatomic, strong, nullable) NSDictionary *responseObject;
@property (nonatomic, strong, nullable) NSError *responseError;


@property (nonatomic, strong) NSString *originalUrl;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *originalParameters;


@property (nonatomic, assign) NKRouterMatchType matchType;
@property (nonatomic, strong, nullable) NSString *matchPath;


@end

NS_ASSUME_NONNULL_END
