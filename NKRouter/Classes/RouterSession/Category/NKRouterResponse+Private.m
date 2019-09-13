//
//  NKRouterResponse+Private.m
//  NKRouterKit
//
//  Created by Nate Kong on 2019/9/12.
//  Copyright © 2019 Nate Kong. All rights reserved.
//

#import "NKRouterResponse+Private.h"

#import "NSError+NKRouter.h"

@implementation NKRouterResponse (Private)

+ (instancetype)responseWithRequest:(NKRouterRequest *)request succeed:(BOOL)succeed responseObject:(NSDictionary *)responseObject error:(NSError *)error {
    NKRouterResponse *response = NKRouterResponse.new;
    response.succeed = succeed;
    response.responseObject = responseObject;
    response.responseError = error;
    
    response.originalUrl = request.requestUrl;
    response.originalParameters = request.requestExtraParameters;
    
    response.matchType = request.matchType;
    response.matchPath = request.matchPath;
    
    return response;
}

+ (instancetype)invalidMatchResponseUrl:(NSString *)originalUrl parameters:(NSDictionary *)originalParameters {
    NKRouterResponse *response = NKRouterResponse.new;
    response.succeed = false;
    response.matchType = NKRouterMatchTypeNone;
    response.responseError = [NSError _NKRouter_responseErrorCode:NKRouterResponseErrorNotMatch];
    
    response.originalUrl= originalUrl;
    response.originalParameters= originalParameters;
    
    return response;
}


@end
