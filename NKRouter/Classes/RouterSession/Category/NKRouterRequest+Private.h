//
//  NKRouterRequest+Private.h
//  NKRouterKit
//
//  Created by Nate Kong on 2019/9/12.
//  Copyright © 2019 Nate Kong. All rights reserved.
//

#import "NKRouterRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface NKRouterRequest (Private) <NSCopying>

+ (instancetype)request:(NSURLComponents *)urlComponents
             parameters:(nullable NSDictionary<NSString *, id> *)parameters
              matchType:(NKRouterMatchType)matchType
              matchPath:(NSString *)matchPath;


@end

NS_ASSUME_NONNULL_END
