//
//  NSError+NKRouter.h
//  NKRouterKit
//
//  Created by Nate Kong on 2019/9/12.
//  Copyright © 2019 Nate Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NKRouterResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSError (NKRouter)

+ (instancetype)_NKRouter_responseErrorCode:(NKRouterResponseError)code;


@end

NS_ASSUME_NONNULL_END
