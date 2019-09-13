//
//  NSError+NKRouter.m
//  NKRouterKit
//
//  Created by Nate Kong on 2019/9/12.
//  Copyright © 2019 Nate Kong. All rights reserved.
//

#import "NSError+NKRouter.h"

NSString * const NKRouterResponseErrorDomain = @"com.nate.router.errorDomain";
@implementation NSError (NKRouter)

+ (instancetype)_NKRouter_responseErrorCode:(NKRouterResponseError)code {
    NSString *description = @"";
    switch (code) {
        case NKRouterResponseErrorNotMatch:
            description = @"can not match any url";
            break;
            
        case NKRouterResponseErrorSessionNotRealize:
            description = @"session which inherited do not realize sessionRequest:completionHandler:";
            break;
            
        default:
            break;
    }
    
    return [NSError errorWithDomain:NKRouterResponseErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: description}];
}


@end
