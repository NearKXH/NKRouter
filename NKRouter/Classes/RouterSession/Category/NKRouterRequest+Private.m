//
//  NKRouterRequest+Private.m
//  NKRouterKit
//
//  Created by Nate Kong on 2019/9/12.
//  Copyright © 2019 Nate Kong. All rights reserved.
//

#import "NKRouterRequest+Private.h"

@implementation NKRouterRequest (Private)

+ (instancetype)request:(NSURLComponents *)urlComponents
             parameters:(nullable NSDictionary<NSString *, id> *)parameters
              matchType:(NKRouterMatchType)matchType
              matchPath:(NSString *)matchPath {
    NKRouterRequest *request = NKRouterRequest.new;
    request.requestUrl = urlComponents.string;
    request.requestExtraParameters = parameters;
    request.matchType = matchType;
    request.matchPath = matchPath;
    
    NSMutableDictionary *par = NSMutableDictionary.new;
    for (NSURLQueryItem *item in urlComponents.queryItems) {
        par[item.name] = item.value;
    }
    request.requestUrlQuery = par;
    [par addEntriesFromDictionary:parameters ?: @{}];
    request.parameters = par;
    
    return request;
}


- (id)copyWithZone:(NSZone *)zone {
    NKRouterRequest *request = [[[self class] allocWithZone:zone] init];
    request.requestUrl = [self.requestUrl copy];
    request.parameters = [self.parameters copy];
    
    request.requestUrlQuery = [self.requestUrlQuery copy];
    request.requestExtraParameters = [self.requestExtraParameters copy];
    
    request.matchType = self.matchType;
    request.matchPath = [self.matchPath copy];
    
    return request;
}


@end
