//
//  NKRouterSession.h
//  NKRouterKit
//
//  Created by Near Kong on 2019/8/31.
//  Copyright © 2019 Near Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NKRouterRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface NKRouterSession : NSObject

/**
 Called when router match the url request.
 Subclasses must override this method to realize itself operation.
 
 @param request Router request info
 @param completionHandler Subclasses should call the completionHandler as soon as you're finished performing that operation.
 
 */
- (void)sessionRequest:(NKRouterRequest *)request completionHandler:(void (^)(BOOL succeed, NSDictionary * _Nullable responseObject, NSError * _Nullable error))completionHandler;


@end

NS_ASSUME_NONNULL_END
