//
//  NKRouterResponse+Private.h
//  NKRouterKit
//
//  Created by Nate Kong on 2019/9/12.
//  Copyright © 2019 Nate Kong. All rights reserved.
//

#import "NKRouterResponse.h"

NS_ASSUME_NONNULL_BEGIN

@class NKRouterRequest;
@interface NKRouterResponse (Private)

+ (instancetype)responseWithRequest:(NKRouterRequest *)request
                            succeed:(BOOL)succeed
                     responseObject:(NSDictionary *)responseObject
                              error:(NSError *) error;

+ (instancetype)invalidMatchResponseUrl:(NSString *)originalUrl parameters:(NSDictionary *)originalParameters;


@end

NS_ASSUME_NONNULL_END
